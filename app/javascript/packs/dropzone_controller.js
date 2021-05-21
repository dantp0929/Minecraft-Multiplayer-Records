const csrf = document.querySelector("meta[name='csrf-token']").getAttribute("content");

Dropzone.autoDiscover = false;

Dropzone.options.trackUploader = {
  paramName: "track[song]",
  url: '/track',
  autoProcessQueue: true,
  uploadMultiple: false,
  parallelUploads: 5,
  addRemoveLinks: true,
  acceptedFiles: "audio/*",
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

      // Track item holds the file name, text field, and dropzone
      var trackItem = document.createElement("div")
      trackItem.className = "track-item";
      trackItem.id = "track" + selectedTrack;
      trackTable.appendChild(trackItem);
      
      var div1 = document.createElement("div");
      div1.className = "file-name-container";
      var div2 = document.createElement("div");
      div2.className = "track-name-container";
      var div3 = document.createElement("div");
      div3.className = "texture-uploader-container";

      var fileName = document.createElement("p");
      fileName.innerHTML = file.name;
      div1.appendChild(fileName);
      trackItem.appendChild(div1);

      var trackName = document.createElement("input");
      trackName.setAttribute("type", "text");
      trackName.setAttribute("value", file.name.split('.').slice(0, -1).join('.'));
      div2.appendChild(trackName);
      trackItem.appendChild(div2);

      // Texture Uploader Dropzone Code
      var textureUploader = document.createElement("form");
      textureUploader.setAttribute("action", "/track/" + selectedTrack);
      textureUploader.className = "dropzone";
      textureUploader.id = "texture-uploader" + selectedTrack;
      textureUploader.setAttribute("method", "patch");
      div3.appendChild(textureUploader);
      trackItem.appendChild(div3);

      var textureUploaderMessage = document.createElement("div");
      textureUploaderMessage.className = "dz-default dz-message";
      textureUploaderMessage.textContent = "Drop texture for track here";
      textureUploader.appendChild(textureUploaderMessage);

      var textureUploaderDropzone = new Dropzone("form#texture-uploader" + selectedTrack, { 
        url: "/track/" + selectedTrack,
        method: "PATCH",
        paramName: "track[texture]",
        autoProcessQueue: true,
        uploadMultiple: false,
        parallelUploads: 5,
        addRemoveLinks: true,
        maxFiles: 1,
        acceptedFiles: "image/png",
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

      var convertBtn = document.getElementById("convert-btn");
      convertBtn.disabled = false;
      convertBtn.textContent = "Convert to a Data Pack!";
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

      if (!document.getElementById("track-table").childElementCount <= 1) {
        document.getElementById("convert-btn").disabled = true;
        document.getElementById("download-section").style.display = "hidden";
      }
    });
  }
}

if (document.getElementById('track-uploader')) {
  var trackDropzone = new Dropzone("form#track-uploader");
}

window.convert = function() {
  disableAll();
  var convertBtn = document.getElementById("convert-btn");
  convertBtn.textContent = "Converting...";

  var ids = [];
  var uuid = document.getElementById("session-uuid").value;

  var progress = document.getElementById("converting-progress");
  progress.setAttribute("aria-valuenow", "33");
  progress.style.width = "33%";
  progress.textContent = "Updating track names... 33%";

  tracks = document.getElementsByClassName("track-item");
  tracks.forEach(element => {
    ids.push(parseInt(element.id.substring(5)));

    // First update each name
    $.ajax({
      type: "PATCH",
      url: "track/" + element.id.substring(5),
      dataType: 'track[name]',
      data: { track: {name: element.childNodes[1].childNodes[0].value } },
      headers: {
        'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
      },
      complete: function(data) {
        // After the last update, download the files
        if (element === tracks[tracks.length-1]) {
          ajaxConvert(ids, uuid)
        }
      }
    });
  });
}

function ajaxConvert(ids, uuid) {
  var progress = document.getElementById("converting-progress");
  progress.setAttribute("aria-valuenow", "66");
  progress.style.width = "66%";
  progress.textContent = "Converting tracks to mono .ogg format... 66%";

  $.ajax({
    type: "POST",
    url: "track/convert",
    dataType: 'track',
    data: { ids: ids, uuid: uuid },
    headers: {
      'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
    },
    complete: function(data) {
      progress.setAttribute("aria-valuenow", "100");
      progress.classList.add("bg-success");
      progress.style.width = "100%";
      progress.textContent = "Completed! Download link will be avaliable for 30 minutes...";

      var convertBtn = document.getElementById("convert-btn");
      convertBtn.textContent = "Converted!";

      document.getElementById("download-section").style.display = "block";
    }
  });
}

function disableAll() {
  document.getElementById("convert-btn").disabled = true;
  document.getElementsByClassName("track-name-container").forEach(element => {
    element.childNodes[0].disabled = true;
  });

  document.getElementsByClassName("dropzone").forEach(element => {
    Dropzone.forElement(element).disable();
  });
}

function enableAll() {
  document.getElementById("convert-btn").disabled = false;
  document.getElementsByClassName("track-name-container").forEach(element => {
    element.childNodes[0].disabled = false;
  });

  document.getElementsByClassName("dropzone").forEach(element => {
    Dropzone.forElement(element).enable();
  });
}
