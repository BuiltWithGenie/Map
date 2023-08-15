module App
using PlotlyBase
using GenieFramework
using DataFrames
using CSV
include("./ui.jl")
include("./constants.jl")
include("./utils.jl")
using .Constants: current_year, ScatterModel, COLOR_SCALE_OPTIONS
using .Utils: scale_array, map_fields
@genietools


@app Model begin
  @in left_drawer_open = true
  @in filter_range::RangeData{Int} = RangeData(0:current_year)
  @in selected_feature::Union{Nothing,String} = nothing
  @in color_scale = "Greens"
  @in animate = false

  @mixin ScatterModel

  @out color_scale_options = COLOR_SCALE_OPTIONS
  @out input_data = DataFrame()
  @out min_year = 0
  @out max_year = current_year
  @out features::Array{String} = []
  @out data = DataFrame()
  @out trace = [scattermapbox()]
  @out layout = PlotlyBase.Layout(
    title="World Map",
    showlegend=false,
    width="1800",
    mapbox=attr(
      style="open-street-map",
    ),
    geo=attr(
      showframe=false,
      showcoastlines=false,
      projection=attr(type="natural earth")
    ))
  @onchange input_data begin
    data = map_fields(input_data)
  end

  @onchange data begin
    features = names(data)
    selected_feature = features[1]

    lon = data[!, "Longitude"]
    lat = data[!, "Latitude"]

    min_year = minimum(data[!, "Date"])
    max_year = maximum(data[!, "Date"])

  end

  @onchange min_year, max_year begin
    filter_range = RangeData(min_year:max_year)
  end

  @onchange selected_feature begin
    marker = attr(
      size=scale_array(data[!, selected_feature]),
      color=data[!, selected_feature],
      colorscale="Greens"
    )
  end

  @onchange color_scale begin
    marker = attr(
      size=marker.size,
      color=marker.color,
      colorscale=color_scale
    )
  end

  @onchange filter_range begin
    filtered_data = filter(i -> i.Date >= first(filter_range.range) && i.Date <= last(filter_range.range), data)
    marker = attr(
      size=scale_array(filtered_data[!, selected_feature]),
      color=filtered_data[!, selected_feature],
      colorscale=marker.colorscale
    )
    # lon = filtered_data[!, "Longitude"],
    # lat = filtered_data[!, "Latitude"]
  end

  @onchange lon, lat, marker begin
    trace = [scattermapbox(
      lat=lat,
      lon=lon,
      marker=marker
    )]
  end

  @onchange animate begin

    if animate

      function cb(_)
        first_year = model.filter_range[].range[1] + 1
        last_year = model.filter_range[].range[end] + 1
        years_diff = last_year - first_year

        if last_year > model.max_year[]
          first_year = model.min_year[]
          last_year = model.min_year[] + years_diff
        end

        model.filter_range[] = RangeData(first_year:last_year)
      end

      global t = Timer(cb, 0.1, interval=0.5)
      wait(t)
    else
      close(t)
    end

  end



end


route("/") do
  global model = Model |> init |> handlers
  return page(model, ui())
end

route("/", method=POST) do
  files = Genie.Requests.filespayload()
  f = first(files)
  model.input_data[] = CSV.read(f[2].data, DataFrame)
  return "Perfecto!"
end

end
