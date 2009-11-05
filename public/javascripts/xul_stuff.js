Object.extend(XULElement.prototype, { 
	replace: function(string) {
		this.parentNode.replaceChild(string.to_e().to_xul(), this);
	} 
});

Object.extend(String.prototype, {
	to_e: function() {
		var doc = new DOMParser().parseFromString(this, "application/xml");
		if (doc.documentElement.tagName == "parseerror") 
			throw("Parsing Error");
		else 
			return doc.documentElement;
	}
});

Object.extend(Element.prototype, {
	to_xul: function() {
		var i, z, xul_element;

		if (this.nodeType == this.ELEMENT_NODE) {
			xul_element = document.createElementNS("http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul", this.localName);
			
			attrs = this.attributes;	
			for (i=0; i < attrs.length; i++) {
				attr = attrs.item(i);
				xul_element.setAttribute(attr.name, attr.value);
			}

			for (z=0; z < this.childNodes.length; z++) {
				if (this.childNodes[z].nodeType == this.ELEMENT_NODE) 
					xul_element.appendChild(this.childNodes[z].to_xul());
				else if (this.childNodes[z].nodeType == this.TEXT_NODE &&
									this.childNodes.length == 1 ) 
					xul_element.textContent = this.textContent;												
			}		
		}
		else if (this.nodeType == this.TEXT_NODE) {
			xul_element = document.createTextNode(this.nodeValue);
		}

		return xul_element;
	} 
});
