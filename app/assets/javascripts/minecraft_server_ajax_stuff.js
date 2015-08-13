$('#start_btn').on('click', function() {
    world_name = get_selected_world();
    $.ajax({
        type: 'get',
        url: 'ajax/start_server',
        data: {world_name:world_name},
    });
    return false;
});
$('#stop_btn').on('click', function() {
    $.ajax({
        type: 'get',
        url: 'ajax/stop_server'
    });
    return false;
});

function get_selected_world() {
    return $("#world_select").children("option").filter(":selected").text()
}
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
