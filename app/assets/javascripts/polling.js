$(function () {
  // check that page has the modal
  if ($('#resque-modal').length > 0) {
    setTimeout(updateStatus, 1000);
  }
});

function updateStatus() {
  var jid = $('#resque-modal').attr('data-jid');
  $.getScript('/status.js?jid=' + jid);

  // terminate polling once job stops
  if ($('#status').hasClass('alert-info')) {
    setTimeout(updateStatus, 2000);
  }
}