const csrf = document.querySelector("meta[name='csrf-token']").getAttribute("content");

Dropzone.options.trackUploader = {
  paramName: "track[song]",
  url: '/track',
  autoProcessQueue: true,
  uploadMultiple: false,
  parallelUploads: 5,
  addRemoveLinks: true,
  headers: {
    'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
  },
  init: function() {
    dzClosure = this; // Makes sure that 'this' is understood inside the functions below.

    // for Dropzone to process the queue (instead of default form behavior):
    // document.getElementById("submit-all").addEventListener("click", function(e) {
    //     // Make sure that the form isn't actually being sent.
    //     e.preventDefault();
    //     e.stopPropagation();
    //     dzClosure.processQueue();
    // });

    //send all the form data along with the files:
    this.on("sendingmultiple", function(data, xhr, formData) {
        // formData.append("firstname", jQuery("#firstname").val());
        // formData.append("lastname", jQuery("#lastname").val());
    });

    var selectedTrack;

    this.on("success", function(file, response) {
      $(file.previewTemplate).find('.dz-remove').attr('id', response.trackId);
      selectedTrack = response.trackId;

      var trackTable = document.getElementById("trackTable");

      var track = document.createElement("div")
      track.className = "trackItem";
      track.id = "track" + selectedTrack;
      
      var fileName = document.createElement("p");
      fileName.innerHTML = file.name;

      track.appendChild(fileName);
      trackTable.appendChild(track);
    });

    this.on("removedfile", function(file) {
      var id = $(file.previewTemplate).find('.dz-remove').attr('id');
      $.ajax({
        type: 'DELETE',
        url: '/track/'+id,
        headers: {
          'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
        },
        dataType: 'json'
      });

      var trackRow = document.getElementById("track" + id);
      trackRow.remove();
    });
  }
}

window.download = function() {
  var ids = [];

  tracks = document.getElementsByClassName("trackItem");
  tracks.forEach(element => {
    ids.push(parseInt(element.id.substring(5)));
  });

  

  $.ajax({
    type: "POST",
    url: "track/download",
    dataType: 'track',
    data: {ids: ids},
    headers: {
      'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
    }
  });
}