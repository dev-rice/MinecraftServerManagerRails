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
    return $("#world_select").children("option").filter(":selected").text();
}

function update_status() {
    $.ajax({
        type: 'get',
        url: 'ajax/get_status',
        success: function(response) {
            update_view(response);
        }
    });
}

function update_view(response) {
    if (response == "true"){
        show_stop_view();
    } else if (response == "false"){
        show_start_view();
    }
}

function show_start_view() {
    $('#start_view').show();
    $('#stop_view').hide();
}

function show_stop_view() {
    $('#stop_view').show();
    $('#start_view').hide();
}

update_status();
setInterval(update_status, 1000);
