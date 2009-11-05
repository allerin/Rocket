// Created by Suhas 
// Organisation - Allerin Technology
// Date - Jan 1, 2009

  function ValidateForm() {
		var name=document.reqsample.name
		var address=document.reqsample.address1
		var city=document.reqsample.city
		var state=document.reqsample.state
		var zip=document.reqsample.zip
		var email=document.reqsample.email
		var heard_from=document.reqsample.heard_from


		if ((name.value==null)||(name.value=="")){
			alert("Please enter your Name")
			name.focus()
			return false
		}

		if ((address.value==null)||(address.value=="")){
			alert("Please enter your Address")
			address.focus()
			return false
		}

		if ((city.value==null)||(city.value=="")){
			alert("Please enter your City")
			city.focus()
			return false
		}

		if ((state.value==null)||(state.value=="")){
			alert("Please enter your State")
			state.focus()
			return false
		}

		if ((zip.value==null)||(zip.value=="")){
			alert("Please enter your Zip")
			zip.focus()
			return false
		}
		
		var message;
        // For Email validation
        if (stringEmpty(email.value)) {
            message = "Error! Please enter your Email.";
            email.focus()
            alert(message);
            return false
        } else if (noAtSign( email.value )) {
            message = "Error! The address \"" + email.value + "\" does not contain an '@' character.";
            email.focus()
            alert(message);
            return false
        } else if (nothingBeforeAt(email.value)) {
            message = "Error! The address \"" + email.value;
            message += "\" must contain at least one character before the '@' character";
            email.focus()
            alert(message);
            return false
        } else if (noLeftBracket(email.value)) {
            message = "Error! The address \"" + email.value;
            message += "\" contains a right square bracket ']',\nbut no corresponding left square bracket '['.";
            email.focus()
            alert(message);
            return false
        } else if (noRightBracket(email.value)) {
            message = "Error! The address \"" + email.value;
            message += "\" contains a left square bracket '[',\nbut no corresponding right square bracket ']'.";
            email.focus()
            alert( message);
            return false
        } else if (noValidPeriod(email.value)) {
            message = "Error! The address \"" + email.value + "\" must contain a period ('.') character.";
            email.focus()
            alert(message);
            return false
        } else if (noValidSuffix(email.value)) {
            message = "Error! The address \"" + email.value;
            message += "\" must contain a two, three or four character suffix.";
            email.focus()
            alert(message);
            return false
        } 
        // Email validation Ends

		if ((heard_from.value==null)||(heard_from.value=="Please Select")){
			alert("Please select 'How did you find us?'")
			heard_from.focus()
			return false
		}
	}
	






function stringEmpty (formField) {
    // CHECK THAT THE STRING IS NOT EMPTY
    if ( formField.length < 1 ) {
        return ( true );
    } else {
        return ( false );
    }
}

function noAtSign (formField) {
    // CHECK THAT THERE IS AN '@' CHARACTER IN THE STRING
    if (formField.indexOf ('@', 0) == -1) {
        return ( true )
    } else {
        return ( false );
    }
}

function nothingBeforeAt (formField) {
    // CHECK THERE IS AT LEAST ONE CHARACTER BEFORE THE '@' CHARACTER
    if ( formField.indexOf ( '@', 0 ) < 1 ) {
        return ( true )
    } else {
        return ( false );
    }
}

function noLeftBracket (formField) {
    // IF EMAIL ADDRESS IN FORM 'user@[255,255,255,0]', THEN CHECK FOR LEFT BRACKET
    if ( formField.indexOf ( '[', 0 ) == -1 && formField.charAt (formField.length - 1) == ']') {
        return ( true )
    } else {
        return ( false );
    }
}

function noRightBracket (formField) {
    // IF EMAIL ADDRESS IN FORM 'user@[255,255,255,0]', THEN CHECK FOR RIGHT BRACKET
    if (formField.indexOf ( '[', 0 ) > -1 && formField.charAt (formField.length - 1) != ']') {
        return ( true );
    } else {
        return ( false );
    }
}

function noValidPeriod (formField) {
    // IF EMAIL ADDRESS IN FORM 'user@[255,255,255,0]', THEN WE ARE NOT INTERESTED
    if (formField.indexOf ( '@', 0 ) > 1 && formField.charAt (formField.length - 1 ) == ']')
        return ( false );

    // CHECK THAT THERE IS AT LEAST ONE PERIOD IN THE STRING
    if (formField.indexOf ( '.', 0 ) == -1)
        return ( true );

    return ( false );
}

function noValidSuffix(formField) {
    // IF EMAIL ADDRESS IN FORM 'user@[255,255,255,0]', THEN WE ARE NOT INTERESTED
    if (formField.indexOf('@', 0) > 1 && formField.charAt(formField.length - 1) == ']') {
        return ( false );
    }

    // CHECK THAT THERE IS A TWO OR THREE CHARACTER SUFFIX AFTER THE LAST PERIOD
    var len = formField.length;
    var pos = formField.lastIndexOf ( '.', len - 1 ) + 1;
    if ( ( len - pos ) < 2 || ( len - pos ) > 4 ) {
        return ( true );
    } else {
        return ( false );
    }
}