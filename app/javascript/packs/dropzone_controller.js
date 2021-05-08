const csrf = document.querySelector("meta[name='csrf-token']").getAttribute("content");

Dropzone.options.trackUploader = {
  paramName: "track[song]",
  url: '/track',
  autoProcessQueue: true,
  uploadMultiple: false,
  parallelUploads: 5,
  addRemoveLinks: true,
  headers: {
    'Content-Type': 'application/json',
    'X-CSRF-Token': csrf
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
        selectedTrack = track.id;
        
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
          dataType: 'json'
        });
      });
  }
}