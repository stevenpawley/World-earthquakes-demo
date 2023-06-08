import shinyswatch
import pandas as pd
from shiny import App, render, ui, reactive
from shinywidgets import output_widget, render_widget
from plotly.express import density_mapbox, bar, scatter
from sklearn.cluster import DBSCAN


# publish using
# rsconnect deploy shiny .  --title 'shiny-python-test'

# download the data
quakes = pd.read_csv('https://raw.githubusercontent.com/plotly/datasets/master/earthquakes-23k.csv')
quakes['Date'] = pd.to_datetime(
    quakes['Date'],
    dayfirst=False,
    yearfirst=False,
    format='mixed',
    utc=True
)
quakes['Year'] = quakes.Date.dt.year

# ui
app_ui = ui.page_fluid(
    shinyswatch.theme.cerulean(),
    ui.panel_title('World Earthquakes'),
    ui.layout_sidebar(
        ui.panel_sidebar(
            ui.input_slider(
                id="year_range",
                label="Years",
                min=1965,
                max=2016,
                value=(1965, 2016),
                sep=''
            ),
            ui.input_action_button('cluster', 'Find clusters'),
            width=3
        ),
        ui.panel_main(
            ui.row(
                'Map view',
                output_widget(id="map")
            ),
            ui.row(
                ui.navset_tab(
                    ui.nav(
                        'Earthquakes vs. date',
                        output_widget(id='barplot')
                    ),
                    ui.nav(
                        'Earthquakes vs. magnitude',
                        output_widget(id='scatterplot')
                    ),
                    ui.nav(
                        'Clusters',
                        ui.output_table('clustertbl')
                    )
                )
            )
        )
    )
)

# server
def server(input, output, session):
    @reactive.Calc
    def filtered():
        df = quakes.loc[
            (quakes.Year >= input.year_range()[0]) & 
            (quakes.Year <= input.year_range()[1])
        ]
        return df
    
    @reactive.Calc
    def yearly():
        byyear = filtered().groupby('Year').size()
        byyear = byyear.reset_index(name='N')
        return byyear

    @output
    @render_widget
    def map():
        fig = density_mapbox(
            data_frame=filtered(),
            lat='Latitude',
            lon='Longitude',
            radius=5,
            mapbox_style = "stamen-terrain",
            center={'lon': 180},
            zoom=0
        )
        return fig
    
    @output
    @render_widget
    def barplot():
        return bar(yearly(), x='Year', y='N')

    @output
    @render_widget
    def scatterplot():
        df = filtered()
        df['Magnitude'] = pd.cut(df.Magnitude, bins=5)
        byyear = df.groupby(['Year', 'Magnitude']).size()
        byyear = byyear.reset_index(name='N')
        return scatter(byyear, x='Year', y='N', color='Magnitude')

    @output
    @render.table
    @reactive.event(input.cluster, ignore_none=False)
    def clustertbl():
        cl = DBSCAN()
        df = filtered()
        df['Cluster'] = cl.fit_predict(df[['Latitude', 'Longitude']])

        cluster_means = df[['Latitude', 'Longitude', 'Cluster']].groupby('Cluster').mean()
        cluster_means = cluster_means.reset_index()
        return cluster_means

app = App(app_ui, server)
