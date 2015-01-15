document.addEventListener("deviceready", onDeviceReady, false);
onDeviceReady = ->
  applican_init()
  db = null
  console.log("Ready")
  applican.openDatabase 'taskDB', (d) ->
    db = d
    db.exec """
    CREATE TABLE IF NOT EXISTS TASKS (id INTEGER PRIMARY KEY AUTOINCREMENT, task TEXT)
    """, (s) ->
      console.log "Table create successful"
      db.query """
      SELECT id, task FROM TASKS
      """,
      (result) ->
        return true if applican.config.debug
        $.each result.rows, (i, row) ->
          html = """
          <div class=\"ui-checkbox\">
            <label for=\"checkbox-v-#{row.id}\" class=\"ui-btn ui-corner-all ui-btn-inherit ui-btn-icon-left ui-checkbox-off\">#{row.task}</label>
    	      <input type=\"checkbox\" name=\"checkbox-v-1a\" id=\"checkbox-v-#{row.id}\" class=\"task\" value=\"#{row.id}\">
          </div>
          """
          $(".tasks fieldset").append html
      , (e) ->
        console.log "SELECT failed."
    , (e) ->
      console.log "Table create failed."
  , (e) ->
    console.log "Open database fail"
  $(".form-task").on 'submit', (e) ->
    e.preventDefault()
    return false if $("#task").val() == ""
    name = $("#task").val()
    sql_safe_name = name.replace("'", "''")
    db.exec """
    INSERT INTO TASKS (task) values ('#{sql_safe_name}')
    """, (result) ->
      console.log "INSERT successful."
      db.query """
      SELECT id, task FROM TASKS ORDER BY id desc LIMIT 1
      """, (rows) ->
        if applican.config.debug
          row = id: 1, task: name
        else
          row = rows.rows[0]
        html = """
        <div class=\"ui-checkbox\">
          <label for=\"checkbox-v-#{row.id}\" class=\"ui-btn ui-corner-all ui-btn-inherit ui-btn-icon-left ui-checkbox-off\">#{row.task}</label>
  	      <input type=\"checkbox\" name=\"checkbox-v-1a\" id=\"checkbox-v-#{row.id}\" class=\"task\" value=\"#{row.id}\">
        </div>
        """
        $(".tasks fieldset").append html
      , (e) ->
         console.log "SELECT failed."
         alert e
    e.target.reset()
  $(".tasks").on 'click', '.task', (e) ->
    e.preventDefault()
    db.exec """
    DELETE FROM TASKS WHERE id = #{$(e.target).val()}
    """, (s) ->
      $(e.target).parents("div.ui-checkbox").remove()
    , (e) ->
      consoole.log e
onDeviceReady()
