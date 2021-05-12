const csrf = document.querySelector("meta[name='csrf-token']").getAttribute("content");

Dropzone.autoDiscover = false;

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
    dzClosure = this;

    var selectedTrack;

    this.on("success", function(file, response) {
      $(file.previewTemplate).find('.dz-remove').attr('id', response.trackId);
      selectedTrack = response.trackId;

      var trackTable = document.getElementById("track-table");

      var trackItem = document.createElement("div")
      trackItem.className = "track-item";
      trackItem.id = "track" + selectedTrack;
      
      var fileName = document.createElement("p");
      fileName.innerHTML = file.name;

      trackTable.appendChild(fileName);
      trackTable.appendChild(trackItem);

      document.getElementById("download-btn").disabled = false;

      // Texture Uploader Dropzone Code
      var textureUploader = document.createElement("form");
      textureUploader.setAttribute("action", "/track/" + selectedTrack);
      textureUploader.setAttribute("class", "dropzone");
      textureUploader.id = "texture-uploader" + selectedTrack;
      textureUploader.setAttribute("method", "patch");

      trackItem.appendChild(textureUploader);

      var textureUploaderDropzone = new Dropzone("form#texture-uploader" + selectedTrack, { 
        url: "/track/" + selectedTrack,
        paramName: "track[song]",
        autoProcessQueue: true,
        uploadMultiple: false,
        parallelUploads: 5,
        addRemoveLinks: true,
        maxFiles: 1,
        headers: {
          'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
        },
        init: function() {
          dzClosure = this;
          this.hiddenFileInput.removeAttribute('multiple');

          var selectedTrack;

          this.on("success", function(file, response) {
            
          });

          this.on("removedfile", function(file) {
            
          });

          this.on("addedfile", function(file) {
            if (this.files.length > 1) {
              this.removeFile(this.files[0]);
            }
          });
        }
      });
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

      if (!document.getElementById("track-table").childElementCount > 0) {
        document.getElementById("download-btn").disabled = true;
      }
    });
  }
}

if (document.getElementById('track-uploader')) {
  var trackDropzone = new Dropzone("form#track-uploader");
}

window.download = function() {
  var ids = [];

  tracks = document.getElementsByClassName("track-item");
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