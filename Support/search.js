var foundFiles = 0;
var foundLines = 0;
var folds;

function $(el) {
  return document.getElementById(el);
}

function f() {
  foundFiles += 1;
  $('filecount').innerText = ('' + foundFiles).concat(' file').concat( (foundFiles == 1 ) ? '' : 's' );
}

function l() {
  foundLines += 1;
  $('linecount').innerText = ('' + foundLines).concat(' line').concat( (foundLines == 1 ) ? '' : 's' );
}

function searchStarted() {
  $('teaser').style.display = 'none';
  folds = new FoldSupport();
}

function searchResultAdded(id) {
  folds.setupFoldingIn($(id));
}

function searchCompleted() {
  $('teaser').style.display = 'block';
  folds.searchComplete();
}

function FoldSupport() {
  this.container = $('fold');
  this.checkbox  = $('fold-toggle');
  this.label     = $('fold-lbl');
}

FoldSupport.prototype = {
  searchComplete: function() {
    this.results = document.querySelectorAll('.file');
    this.toggle();
    this.setupObservers();
  },
  
  toggle: function() {
    if(this.container.style.display == 'none') {
      this.container.style.display = 'block';
    } else {
      this.container.style.display = 'none';
    }
  },
  
  foldAll: function(fold) {
    var display = 'none';
    if(fold) { display = 'block'; }
    for (var i=0; i < this.results.length; i++) {
      var file = this.results[i];
      var matches = file.getElementsByTagName('tbody')[0];
      matches.style.display = display;
    };
  },
  
  setupObservers: function() {
    this.setupMainFolding();
  },
  
  setupMainFolding: function() {
    var self = this;
    this.checkbox.addEventListener('change', function() {
      var lbl = self.label.innerHTML;
      if(lbl.indexOf('Unfold') == -1) {
        self.label.innerHTML = 'Unfold Results';
      } else {
        self.label.innerHTML = 'Fold results';
      }
      
      self.foldAll(lbl.indexOf('Unfold') != -1);
    }, false);
  },
  
  setupFoldingIn: function(node) {
    var self = this;
    var hdr = node.getElementsByTagName('thead')[0];
    hdr.addEventListener('click', function() {
      var parent = this.parentNode;
      if(parent.tagName.toLowerCase() == 'table') {
        self.toggleMatchesIn(parent);
      }
    }, false);
  },
  
  toggleMatchesIn: function(table) {
    var matches = table.querySelector('.matches');
    if(matches.style.display == 'none')
      matches.style.display = 'block';
    else
      matches.style.display = 'none';
  }
}
