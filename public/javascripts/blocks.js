// ===========================================================================
// SETTINGS
// ===========================================================================

var hoverExitDelay = 600
var slideDuration = 0.2
var lastHoverTimer = null
var lastHoverCommand = null

function clearCurrentHover() {
  if(!lastHoverTimer) return
  clearTimeout(lastHoverTimer)
  eval(lastHoverCommand)
  lastHoverTimer = null
  lastHoverCommand = null
}

function hoverEndWith(command) {
  lastHoverCommand = command
  lastHoverTimer = setTimeout(command, hoverExitDelay)
}

function showElement(element, options) {
  if($(element) && !Element.visible(element)) {
    options = options || {}
    new Effect.BlindDown(element, {duration: slideDuration,
      afterFinish: function() {
        Element.undoClipping(element)
        $(element).style.width = "auto"
        $(element).style.height = "auto"
        if(options.afterFinish) options.afterFinish()
      }})
  }
}

function hideElement(element, options) {
  if($(element) && Element.visible(element)) {
    options = options || {}
    new Effect.BlindUp(element, {duration: slideDuration,
      afterFinish: function() {
        Element.undoClipping(element)
        Element.hide(element)
        if(options.afterFinish) options.afterFinish()
      }})
  }
}

// ===========================================================================
// NOTES BLOCK MANAGER
// ===========================================================================

var notesBlock = {
  show: function() {
    Element.hideIf('notes_link_off', 'blank_slate')
    Element.showIf('notes_link_on')
    showElement('notes_block')
  },

  isEmpty: function() {
    return Element.empty('notes')
  },

  hoverBegin: function(id) {
    clearCurrentHover()
    toggle_edit_link(true, 'show_note_' + id, 'edit_note_' + id + '_link')
  },

  hoverEnd: function(id, delay) {
    if(delay)
      hoverEndWith("notesBlock.hoverEnd(" + id + ")")
    else
      toggle_edit_link(false, 'show_note_' + id, 'edit_note_' + id + '_link')
  },

  hide: function() {
    Element.hideIf('notes_link_on')
    Element.showIf('notes_link_off')
    hideElement('notes_block')
  },

  display: function(id) {
    this.show()
    Element.showIf('addnote')
    Element.hideIf('notes_indicator', 'addnotedialog')
    
    if (this.notesCount < 2) {
      Element.hide('reorder_notes', 'addnote_separator')
    } else {
      Element.show('reorder_notes', 'addnote_separator')
    }
    
    if(id) {
      Element.hideIf('edit_note_' + id)
      Element.showIf('show_note_' + id)
      toggle_edit_link(false, 'show_note_' + id, 'edit_note_' + id + '_link')
    }
  },

  edit: function(id) {
    this.show()
    if(id) {
      this.editExisting(id)
    } else {
      this.reorderComplete(
        document.getElementsByClassName('note_dragger'),
        document.getElementsByClassName('note_content')
      )
      this.addNew()
    }
  },

  addNew: function() {
    Element.showIf('addnotedialog')
    Element.hideIf('addnote', 'notes_indicator')
    Field.clear('new_note_title', 'new_note_body')
    // this bizarre little hack is to prevent FF from scrolling to the top of
    // the notes block when the new_note_title field is focused (reported by
    // Marc Hedlund)
    setTimeout("Field.focus('new_note_title')",10)
  },

  editExisting: function(id) {
    Element.hideIf('addnote', 'addnotedialog', 'show_note_' + id)
    Element.showIf('edit_note_' + id)
    Field.focus('note_title_' + id)
  },

  processing: function() {
    Element.showIf('notes_indicator')
  },

  checkEmpty: function(skip_display) {
    if(this.isEmpty()) {
      this.hide()
      pageManager.checkEmpty()
      return true
    } else if(!skip_display) {
      this.display()
      return false
    }
  },

  addCompleted: function(request) {
    this.notesCount += 1
    id = 'note_' + request.getResponseHeader('BackpackNoteID')
    scrollWindowTo(id)
    new Effect.Highlight(id)
    this.display()
  },

  noteDeleted: function() {
    this.notesCount -= 1
    this.checkEmpty()
  },

  reorder: function() {
    controls = document.getElementsByClassName('note_dragger')
    contents = document.getElementsByClassName('note_content')
    if(!controls) return
    
    this.makeDraggable()

    if(!Element.visible(controls[0])) {
      toggle_edit_link_possible = false
      this.reorderBegin(controls, contents)
    } else {
      toggle_edit_link_possible = true
      this.reorderComplete(controls, contents)
    }
  },

  reorderBegin: function(controls, contents) {
    Element.showAll(controls)
    Element.hideAll(contents)
  },

  reorderComplete: function(controls, contents) {
    Element.hideAll(controls)
    Element.showAll(contents)
  },

  makeDraggable: function() {
    if ($('notes').sortable_tag) {
      return true;
    } else {
      Sortable.create('notes', {
        tag: 'div',
        handle:'dragger',
        onUpdate:function(element) { 
          new Ajax.Request(
            noteReorderUrl,
            { parameters:Sortable.serialize('notes'), asynchronous:true }
          )
        }
      });  
    }
  }
}

//
// MISC
//

var toggle_edit_link_possible = true;

function toggle_edit_link(on, show_container, edit_container) {
  if (toggle_edit_link_possible == false) return
  
  if (on) {
    if($(show_container)) $(show_container).style.background='url(/images/hover-gradient.gif) left repeat-y'
    Element.showIf(edit_container, edit_container + "2")
  } else {
    if($(show_container)) $(show_container).style.background='none'
    Element.hideIf(edit_container, edit_container + "2")
  }
}

Element.empty = function(id) {
  return $(id).innerHTML.match(/^\s*$/);
}

Element.visible = function(element) {
  return ($(element).style.display != "none")
}

Element.showAll = function(array) {
  Element.show.apply(Element.show, array)
}

Element.hideAll = function(array) {
  Element.hide.apply(Element.hide, array)
}

Element.showIf = function() {
  for(var i = 0; i < arguments.length; i++ ) {
    var element = $(arguments[i])
    if(element) Element.show(element)
  }
}

Element.hideIf = function() {
  for(var i = 0; i < arguments.length; i++ ) {
    var element = $(arguments[i])
    if(element) Element.hide(element)
  }
}

function scrollWindowTo(id) {
  element = $(id)
  x = ( element.x ? element.x : element.offsetLeft )
  y = ( element.y ? element.y : element.offsetTop )
  window.scrollTo(x,y)
}
