	
		function player_console (message){
			var li = document.createElement("p");
			var d=new Date();
		 	li.innerHTML = d.toUTCString() + " : " + message;
		 	var div = document.getElementById("logs");
		 	//div.appendChild(li);   			 	
		 	div.insertBefore(li, div.firstChild);
		 	if (div.childNodes.length>50)
		 	{
		 		div.removeChild(div.lastChild);
		 	}
		}