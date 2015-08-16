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

function update_log() {
    $.ajax({
        type: 'get',
        url: 'ajax/get_server_log',
        success: function(response) {
            set_log_text(response);
        }
    });
}

function set_log_text(log_text) {
    $('#log_output_div').html(break_log_into_paragraphs(log_text));
}

function break_log_into_paragraphs(log_text) {
    lines_arr = log_text.split("\n");

    return turn_line_arr_into_paragraph_arr(lines_arr);
}

function turn_line_arr_into_paragraph_arr(lines_arr) {
    lines_arr.forEach(function(line, index, array) {
        array[index] = line_into_paragraph(line)
    });
    return lines_arr;
}

function line_into_paragraph(line) {
    if (line == "") {
        return "";
    }
    class_name = "log_paragraph";
    paragraph_line = "<p class=\"" + class_name + "\">" + line + "</p>";
    return paragraph_line;
}

update_status();
setInterval(update_status, 1000);

setInterval(update_log, 1000);
