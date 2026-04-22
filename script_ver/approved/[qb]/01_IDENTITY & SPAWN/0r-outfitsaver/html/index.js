outfitMenuOpen = false;
dialogOpen = false;
tagsData = [];
outfitsData = [];
translations = [];
window.addEventListener('message', function(event) {
    ed = event.data;
	if (ed.action === "openOutfitMenu") {
		translations = ed.translations;
		for (var key in translations) {
			if (translations.hasOwnProperty(key)) {
				var elements = document.getElementsByClassName(key);
				for (var i = 0; i < elements.length; i++) {
					elements[i].innerHTML = translations[key];
				}
			}
		}
		document.getElementById("mainDivTop2Input").placeholder = translations.search_outfit;
		document.getElementById("mainText2").innerHTML=`${translations.title_1} <span style="color: rgba(255, 255, 255, 0.60);">${translations.title_2}</span>`;
		outfitMenuOpen = true;
		document.getElementById("mainDivOutsideButtons").style.display = "flex";
		document.getElementById("mainDiv").style.display = "flex";
		document.getElementById("mainDivEffect").style.display = "flex";
		document.getElementById("mainDivOutfitsDivInside").innerHTML=``;
		outfitsData = ed.outfits;
		outfitsData.forEach(function(outfitData, index) {
			if (outfitData && outfitData.id) {
				tagsData[outfitData.id] = outfitData.tags;
				var outfitHTML = `
				<div id="mainDivOutfitDiv">
					<div id="mainDivOutfitDivTop">
						<div id="mainDivOutfitDivTopRight">
							<div id="mainDivOutfitDivTopRightInside">
								<h4 style="margin-top: 8%;">${outfitData.outfitname}</h4>
								<div class="mainDivOutfitDivTopRightInsideTags" id="mainDivOutfitDivTopRightInsideTags-${outfitData.id}"></div>
							</div>
						</div>
						<div id="mainDivOutfitDivTopLeft"><i class="fa-solid fa-shirt" style="margin-top: 3%;"></i></div>
					</div>
					<div id="mainDivOutfitDivBottom">
						<div id="mainDivOutfitDivBottomBtn" class="mainDivOutfitDivBottomBtnBlue" onclick="wearOutfit('${outfitData.outfitname}', '${outfitData.id}')"><i class="fa-solid fa-shirt" style="margin-top: 3%;"></i></div>
						<div id="mainDivOutfitDivBottomBtn" class="mainDivOutfitDivBottomBtnOrange" onclick="viewOutfit('${outfitData.outfitname}', '${outfitData.id}')"><i class="fa-solid fa-eye" style="margin-top: 3%;"></i></div>
						<div id="mainDivOutfitDivBottomBtn" class="mainDivOutfitDivBottomBtnLime" onclick="editOutfit('${outfitData.outfitname}', '${outfitData.id}')"><i class="fa-solid fa-pencil" style="margin-top: 3%;"></i></div>
						<div id="mainDivOutfitDivBottomBtn" class="mainDivOutfitDivBottomBtnRed" onclick="deleteOutfit('${outfitData.outfitname}', '${outfitData.id}')"><i class="fa-solid fa-trash" style="margin-top: 3%;"></i></div>
					</div>
				</div>
				`;
				appendHtml(document.getElementById("mainDivOutfitsDivInside"), outfitHTML);
				if (document.getElementById(`mainDivOutfitDivTopRightInsideTags-${outfitData.id}`)) {
					tagsData[outfitData.id].forEach(function(outfitTagData, index) {
						if (outfitTagData) {
							var outfitTagsHTML = `<div id="mainDivOutfitDivTopRightInsideTag"><h4>${outfitTagData}</h4></div>`;
							appendHtml(document.getElementById(`mainDivOutfitDivTopRightInsideTags-${outfitData.id}`), outfitTagsHTML);
						} else {
							var outfitTagsHTML = `<div id="mainDivOutfitDivTopRightInsideTag"><h4>${translations.no_tags}</h4></div>`;
							appendHtml(document.getElementById(`mainDivOutfitDivTopRightInsideTags-${outfitData.id}`), outfitTagsHTML);
						}
					});
					const scrollContainer = document.getElementById(`mainDivOutfitDivTopRightInsideTags-${outfitData.id}`);
					scrollContainer.addEventListener("wheel", (event) => {
						event.preventDefault();
						const delta = event.deltaY * 0.5;
						scrollContainer.scrollLeft += delta;
					});
				}
			}
		});
	} else if (ed.action === "closeOutfitMenu") {
		outfitMenuOpen = false;
		document.getElementById("mainDiv").style.display = "none";
		document.getElementById("mainDivEffect").style.display = "none";
		document.getElementById("mainDivOutsideButtons").style.display = "none";
		post({action: "nuiFocus"});
	}
	document.onkeyup = function(data) {
		if (data.which == 27 && outfitMenuOpen) {
            outfitMenuOpen = false;
			document.getElementById("mainDiv").style.display = "none";
			document.getElementById("mainDivEffect").style.display = "none";
			document.getElementById("mainDivOutsideButtons").style.display = "none";
			dialogOpen = false;
			document.getElementById("mainDivOutfitsDivInside").style.filter = dialogOpen ? "blur(5px)" : "none";
			document.getElementById("mainDivDialog").style.display = dialogOpen ? "flex" : "none";
			post({action: "nuiFocus"});
		}
		if (data.which == 37 && outfitMenuOpen) {
			post({action: 'updateRotation', rotationDelta: -30.5})
		}
		if (data.which == 39 && outfitMenuOpen) {
			post({action: 'updateRotation', rotationDelta: 30.5})
		}
		if (data.which == 38 && outfitMenuOpen) {
			post({action: 'updateZoom', type: "zoomOut"})
		}
		if (data.which == 40 && outfitMenuOpen) {
			post({action: 'updateZoom', type: "zoomIn"})
		}
	}
})

function appendHtml(el, str) {
	var div = document.createElement('div');
	div.innerHTML = str;
	while (div.children.length > 0) {
		el.appendChild(div.children[0]);
	}
}

function wearOutfit(name, id) {
	post({action: "wearOutfit", outfitName: name, id: Number(id)});
}

function viewOutfit(name, id) {
	post({action: "viewOutfit", outfitName: name, id: Number(id)});
}

function editOutfit(name, id) {
	dialogOpen = !dialogOpen;
	document.getElementById("mainDivOutfitsDivInside").style.filter = dialogOpen ? "blur(5px)" : "none";
	document.getElementById("mainDivDialog").style.display = dialogOpen ? "flex" : "none";
	document.getElementById("mainDivDialog").innerHTML=`
	<h4 id="mainDivDialogH4">${translations.edit_outfit}</h4>
	<span id="mainDivDialogSpan">${translations.edit_outfit_2}</span>
	<input type="text" class="mainDivDialogInput" id="mainDivDialogInput-OutfitName" placeholder="${translations.outfit_name}">
	<input type="text" class="mainDivDialogInput" id="mainDivDialogInput-Tags" placeholder="${translations.outfit_tags}">
	<div id="mainDivDialogButtons">
		<div class="mainDivDialogButtonGreen" onclick="editOutfit2('${id}')">${translations.save_changes}</div>
		<div class="mainDivDialogButtonRed" onclick="closeDialog()">${translations.cancel}</div>
	</div>
	`;
	document.getElementById("mainDivDialogInput-OutfitName").value=name;
	document.getElementById("mainDivDialogInput-Tags").value=tagsData[Number(id)].join(', ');
}

function editOutfit2(id) {
	let outfitName = document.getElementById("mainDivDialogInput-OutfitName").value;
	let tags = document.getElementById("mainDivDialogInput-Tags").value;
	let tagsTable = tags.split(',').map(tag => tag.trim());
	post({action: "editOutfit", id: Number(id), outfitName: outfitName, tags: tagsTable});
	closeDialog();
}

function createNewOutfit() {
	dialogOpen = !dialogOpen;
	document.getElementById("mainDivOutfitsDivInside").style.filter = dialogOpen ? "blur(5px)" : "none";
	document.getElementById("mainDivDialog").style.display = dialogOpen ? "flex" : "none";
	document.getElementById("mainDivDialog").innerHTML=`
	<h4 id="mainDivDialogH4">${translations.create_outfit}</h4>
	<span id="mainDivDialogSpan">${translations.create_outfit_2}</span>
	<input type="text" class="mainDivDialogInput" id="mainDivDialogInput-OutfitName" placeholder="${translations.outfit_name}">
	<input type="text" class="mainDivDialogInput" id="mainDivDialogInput-Tags" placeholder="${translations.outfit_tags}">
	<div id="mainDivDialogButtons">
		<div class="mainDivDialogButtonGreen" onclick="createNewOutfit2()">${translations.create_outfit}</div>
		<div class="mainDivDialogButtonRed" onclick="closeDialog()">${translations.cancel}</div>
	</div>
	`;
}

function createNewOutfit2() {
	let outfitName = document.getElementById("mainDivDialogInput-OutfitName").value;
	let tags = document.getElementById("mainDivDialogInput-Tags").value;
	let tagsTable = tags.split(',').map(tag => tag.trim());
	post({action: "saveOutfit", outfitName: outfitName, tags: tagsTable});
	closeDialog();
}

function closeDialog() {
	dialogOpen = !dialogOpen;
	document.getElementById("mainDivOutfitsDivInside").style.filter = dialogOpen ? "blur(5px)" : "none";
	document.getElementById("mainDivDialog").style.display = dialogOpen ? "flex" : "none";
}

function deleteOutfit(name, id) {
	dialogOpen = !dialogOpen;
	document.getElementById("mainDivOutfitsDivInside").style.filter = dialogOpen ? "blur(5px)" : "none";
	document.getElementById("mainDivDialog").style.display = dialogOpen ? "flex" : "none";
	document.getElementById("mainDivDialog").innerHTML=`
	<h4 id="mainDivDialogH4">${translations.delete_outfit}</h4>
	<span id="mainDivDialogSpan">${translations.delete_outfit_2}</span>
	<div id="mainDivDialogButtons">
		<div class="mainDivDialogButtonGreen" onclick="deleteOutfit2('${name}', '${id}')">${translations.delete_outfit}</div>
		<div class="mainDivDialogButtonRed" onclick="closeDialog()">${translations.cancel}</div>
	</div>
	`;
}

function deleteOutfit2(name, id) {
	post({action: "deleteOutfit", outfitName: name, outfitId: Number(id)});
	closeDialog();
}

let isMouseDown = false;
window.addEventListener('mousedown', function(event) {
	if (event.button === 0 && checkIsInPedDiv(event)) {
		isMouseDown = true;
	}
});

window.addEventListener('mouseup', function(event) {
	if (event.button === 0 && checkIsInPedDiv(event)) {
		isMouseDown = false;
	}
});

window.addEventListener('mousemove', function(event) {
	if (isMouseDown && checkIsInPedDiv(event)) {
		const deltaX = event.movementX || event.mozMovementX || event.webkitMovementX || 0;
		if (deltaX !== 0) {
			post({action: "updateRotation", rotationDelta: deltaX});
		}
	}
});

window.addEventListener('wheel', function(event) {
    if (checkIsInPedDiv(event)) {
        const zoomType = event.deltaY < 0 ? "zoomOut" : "zoomIn";
        post({action: "updateZoom", type: zoomType});
    }
});

function checkIsInPedDiv(event) {
	const pedDiv = document.getElementById('pedDiv');
	const rect = pedDiv.getBoundingClientRect();
	const isInDiv = (
		event.clientX >= rect.left &&
		event.clientX <= rect.right &&
		event.clientY >= rect.top &&
		event.clientY <= rect.bottom
	);
	return isInDiv
}

function post(data) {
	var xhr = new XMLHttpRequest();
	xhr.open("POST", `https://${GetParentResourceName()}/callback`, true);
	xhr.setRequestHeader('Content-Type', 'application/json');
	xhr.send(JSON.stringify(data));
}

showRotateCamButtonsState = false;
function showRotateCamButtons() {
	if (showRotateCamButtonsState) {
		showRotateCamButtonsState = false;
		document.getElementById("mainDivOutsideButton-RotaterMenu").classList.remove("mainDivOutsideButtonActive");
		document.getElementById("mainDivOutsideButton-LeftRotate").style.display = "none";
		document.getElementById("mainDivOutsideButton-RightRotate").style.display = "none";
	} else {
		showRotateCamButtonsState = true;
		document.getElementById("mainDivOutsideButton-RotaterMenu").classList.add("mainDivOutsideButtonActive");
		document.getElementById("mainDivOutsideButton-LeftRotate").style.display = "flex";
		document.getElementById("mainDivOutsideButton-RightRotate").style.display = "flex";
	}
}

showClothRemoveButtonsState = false;
function showClothRemoveButtons() {
	if (showClothRemoveButtonsState) {
		showClothRemoveButtonsState = false;
		document.getElementById("mainDivOutsideButton-ClothRemoverMenu").classList.remove("mainDivOutsideButtonActive");
		document.getElementById("mainDivOutsideButton-Hat").style.display = "none";
		document.getElementById("mainDivOutsideButton-Masks").style.display = "none";
		document.getElementById("mainDivOutsideButton-Glasses").style.display = "none";
		document.getElementById("mainDivOutsideButton-Jacket").style.display = "none";
		document.getElementById("mainDivOutsideButton-Bag").style.display = "none";
		document.getElementById("mainDivOutsideButton-Hairs").style.display = "none";
		document.getElementById("mainDivOutsideButton-Shoes").style.display = "none";
		document.getElementById("mainDivOutsideButton-Pants").style.display = "none";
	} else {
		showClothRemoveButtonsState = true;
		document.getElementById("mainDivOutsideButton-ClothRemoverMenu").classList.add("mainDivOutsideButtonActive");
		document.getElementById("mainDivOutsideButton-Hat").style.display = "flex";
		document.getElementById("mainDivOutsideButton-Masks").style.display = "flex";
		document.getElementById("mainDivOutsideButton-Glasses").style.display = "flex";
		document.getElementById("mainDivOutsideButton-Jacket").style.display = "flex";
		document.getElementById("mainDivOutsideButton-Bag").style.display = "flex";
		document.getElementById("mainDivOutsideButton-Hairs").style.display = "flex";
		document.getElementById("mainDivOutsideButton-Shoes").style.display = "flex";
		document.getElementById("mainDivOutsideButton-Pants").style.display = "flex";
	}
}

showMouseInfosState = false;
function showMouseInfos() {
	showMouseInfosState = !showMouseInfosState;
	if (showMouseInfosState) {
		document.getElementById("mainDivOutsideButton-showMouseInfos").classList.add("mainDivOutsideButtonActive");
		document.getElementById("mouseInfosDiv").style.display = "flex";
	} else {
		document.getElementById("mouseInfosDiv").style.display = "none";
		document.getElementById("mainDivOutsideButton-showMouseInfos").classList.remove("mainDivOutsideButtonActive");
	}
}

document.getElementById("mainDivTop2Input").addEventListener('input', (e) => {
	const searchData = e.target.value.toLowerCase();
	const filterData = outfitsData.filter((outfit) => {
		return (outfit.outfitname.toLocaleLowerCase().includes(searchData))
	});
	displayOutfits(filterData);
});

const displayOutfits = (outfits) => {
	document.getElementById("mainDivOutfitsDivInside").innerHTML = outfits.map((outfit) => {
		var {outfitname, id} = outfit;
		return (
		`<div id="mainDivOutfitDiv">
			<div id="mainDivOutfitDivTop">
				<div id="mainDivOutfitDivTopRight">
					<div id="mainDivOutfitDivTopRightInside">
						<h4 style="margin-top: 8%;">${outfitname}</h4>
						<div class="mainDivOutfitDivTopRightInsideTags" id="mainDivOutfitDivTopRightInsideTags-${id}"></div>
					</div>
				</div>
				<div id="mainDivOutfitDivTopLeft"><i class="fa-solid fa-shirt" style="margin-top: 3%;"></i></div>
			</div>
			<div id="mainDivOutfitDivBottom">
				<div id="mainDivOutfitDivBottomBtn" class="mainDivOutfitDivBottomBtnBlue" onclick="wearOutfit('${outfitname}', '${id}')"><i class="fa-solid fa-shirt" style="margin-top: 3%;"></i></div>
				<div id="mainDivOutfitDivBottomBtn" class="mainDivOutfitDivBottomBtnOrange" onclick="viewOutfit('${outfitname}', '${id}')"><i class="fa-solid fa-eye" style="margin-top: 3%;"></i></div>
				<div id="mainDivOutfitDivBottomBtn" class="mainDivOutfitDivBottomBtnLime" onclick="editOutfit('${outfitname}', '${id}')"><i class="fa-solid fa-pencil" style="margin-top: 3%;"></i></div>
				<div id="mainDivOutfitDivBottomBtn" class="mainDivOutfitDivBottomBtnRed" onclick="deleteOutfit('${outfitname}', '${id}')"><i class="fa-solid fa-trash" style="margin-top: 3%;"></i></div>
			</div>
		</div>`
		)
	}).join('');
	outfits.map((outfit) => {
		var {outfitname, id, tags} = outfit;
		tagsData[id] = tags;
		if (document.getElementById(`mainDivOutfitDivTopRightInsideTags-${id}`)) {
			tagsData[id].forEach(function(outfitTagData, index) {
				if (outfitTagData) {
					var outfitTagsHTML = `<div id="mainDivOutfitDivTopRightInsideTag"><h4>${outfitTagData}</h4></div>`;
					appendHtml(document.getElementById(`mainDivOutfitDivTopRightInsideTags-${id}`), outfitTagsHTML);
				} else {
					var outfitTagsHTML = `<div id="mainDivOutfitDivTopRightInsideTag"><h4>${translations.no_tags}</h4></div>`;
					appendHtml(document.getElementById(`mainDivOutfitDivTopRightInsideTags-${id}`), outfitTagsHTML);
				}
			});
			const scrollContainer = document.getElementById(`mainDivOutfitDivTopRightInsideTags-${id}`);
			scrollContainer.addEventListener("wheel", (event) => {
				event.preventDefault();
				const delta = event.deltaY * 0.5;
				scrollContainer.scrollLeft += delta;
			});
		}
	}).join('');
}