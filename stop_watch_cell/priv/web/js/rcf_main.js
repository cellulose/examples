// bindRcfCtls
//
// Walks the document and looks for instances of classes containing rcf, and creates
// controls that map to the appropriate classes.

function bindRcfCtls() {    

    var rcfCtrlMap = {
        'digits':   rcf.ctrls.Digits,
        'knob':     rcf.ctrls.Knob,
        'switch':   rcf.ctrls.Switch
    }
    
    for (var key in rcfCtrlMap) {
        $(".rcf."+ key).each(function(i) {
            this.ctl = new rcfCtrlMap[key](this);
        })
    }
    
}

// disable bounce effect in mobile safari for iOS

// $(document).bind('touchmove', function(e) { e.preventDefault(); });

// Not sure why we need this setTimeout but apparently we do - to ensure that things
// are fully loaded somehow.

$(function() { 
    return setTimeout(bindRcfCtls(), 200); 
});
