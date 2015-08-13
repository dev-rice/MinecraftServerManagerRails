$('#start_btn').on('click', function() {
    console.log("You clicked the start button!");
    world_name = $("#world_select").children("option").filter(":selected").text()
    console.log("Looks like you want to start the world: " + world_name);
    $.ajax({
        type: 'get',
        url: 'ajax/start_server',
        data: {world_name:world_name},
    });
    return false;
});
$('#stop_btn').on('click', function() {
    console.log("You clicked the stop button!");
    $.ajax({
        type: 'get',
        url: 'ajax/stop_server'
    });
    return false;
});
function update_status() {
    $.ajax({
        type: 'get',
        url: 'ajax/get_status',
        success: function(response) {
            $('#status_text').html("Running: " + response);
        }
    });
    return false;
}
update_status();
setInterval(update_status, 1000);
