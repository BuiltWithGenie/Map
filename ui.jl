
ui = () -> StippleUI.layout(
  [
    quasar(:header, toolbar(
      [
      btn(; dense=true, flat=true, round=true, icon="menu", @click("left_drawer_open = !left_drawer_open")),
      toolbartitle("World Map")
    ],
    ),
    ),
    drawer(
      [uploader(label="Upload Dataset", accept=".csv", method="POST", url="http://127.0.0.1:8000/", @on(:uploaded, :uploaded), style="width:200px"),
        quasar(:color, var"v-model"=:selected_color, label="Color"),
        item([itemsection(btn(; dense=true, flat=true, round=true, icon="arrow_right"); avatar=true), itemsection(slider(1:5:100, :current_year))]),
        h1("{{current_year}}")
      ],
      var"v-model"=:left_drawer_open, side="left", width=200, bordered=true, overlay=true
    ),
    page_container(
      plot(:trace, layout=:layout, class="window-height")
    ),
  ],
  view="hHh lpR fFf",
  class="window-height"
)

