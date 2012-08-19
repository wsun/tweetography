$(function () {
  // check that page has the modal
  if ($('#resque-modal').length > 0) {
    setTimeout(updateStatus, 1000);
  }
});

function updateStatus() {
  var jid = $('#resque-modal').attr('data-jid');
  $.getScript('/status.js?jid=' + jid);
  setTimeout(updateStatus, 2000);
}

// TODO: clearTimeout conditionally