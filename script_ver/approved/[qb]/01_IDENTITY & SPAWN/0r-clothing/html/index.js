generalData = [];
variationsData = [];
variationTexturesData = [];
selectedComponentVariationData = {};
currentPlayerSkin = [];
currentPlayerTattoos = [];
currentPlayerTattoos2 = [];
expandButtonData = [];
clothMenuOpen = false;
dialogOpen = false;
selectedPed = null;
creatingChar = false;
clothPayment = 0;
basketData = [];
tattoosData = [];
menuType = [];
shopType = null;
selectedPage2 = null;
currentPedGender = null;
translations = [];
currency = "";
clothStoreCategories = [];
clothStoreCategoriesLength = 0;
choosedPed = null;
enableCompareState = false;
savedClothData = {};
window.addEventListener('message', function(event) {
    ed = event.data;
	if (ed.action === "openCreateCharMenu") {
		translations = ed.translations;
		creatingChar = true;
		shopType = "charcreation";
		menuType = ed.menuType;
		document.getElementById("MDLBottomBtnPink").innerHTML=`<span class="finish"></span>`;
		document.getElementById('MDLBottomBtnPink').setAttribute("onclick", `finishCharacterCreation()`);
		clothStoreCategories = ed.categories;
		clothStoreCategoriesLength = ed.categoriesLength;
		document.getElementById("mainDivOutsideButtons").style.display = "flex";
		document.getElementById("MDLTopEffect").innerHTML=`
		<span style="font-family: 'Gilroy-UltraLight'; letter-spacing: 0.5vw; font-weight: 265; font-size: 0.8vw; margin-left: 0.9vw; margin-top: 2%;">${translations.character}</span>
		<h4 style="font-family: 'Gilroy-BlackItalic'; font-weight: 900; font-size: 1.4vw;">${translations.creator} ${translations.menu}</h4>
		<span style="font-family: 'Gilroy-RegularItalic'; font-weight: 400; color: rgba(255, 255, 255, 0.85); text-transform: capitalize; width: 55%; font-size: 0.7vw;">${translations.character_creator_description}</span>
		`;
		document.getElementById("mainDiv-Menu").style.display = "flex";
		document.getElementById("mainDivEffect").style.display = "flex";
		selectedPage2 = 1;
		generalData = ed.generalData;
		selectedComponentVariationData = {};
		// Face One
		selectedComponentVariationData["FaceOne"] = {};
		selectedComponentVariationData["FaceOne"].num = -1;
		// Skin One
		selectedComponentVariationData["SkinOne"] = {};
		selectedComponentVariationData["SkinOne"].num = -1;
		// Face Two
		selectedComponentVariationData["FaceTwo"] = {};
		selectedComponentVariationData["FaceTwo"].num = -1;
		// Skin Two
		selectedComponentVariationData["SkinTwo"] = {};
		selectedComponentVariationData["SkinTwo"].num = -1;
		// Face Three
		selectedComponentVariationData["FaceThree"] = {};
		selectedComponentVariationData["FaceThree"].num = -1;
		// Skin Three
		selectedComponentVariationData["SkinThree"] = {};
		selectedComponentVariationData["SkinThree"].num = -1;
		openCreateCharMenu(ed.gender);
		document.getElementById("pedDiv").style.display = "flex";
		document.getElementById("pedDiv2").style.display = "none";
		document.getElementById("pedDiv3").style.display = "none";
		document.getElementById("mainDivOutsideButtonDiv-ClothCompare").style.display = "none";
	} else if (ed.action === "openCreateCharMenuWithoutReset") {
		translations = ed.translations;
		creatingChar = true;
		shopType = "charcreation"
		menuType = ed.menuType;
		document.getElementById("MDLBottomBtnPink").innerHTML=`<span class="finish"></span>`;
		document.getElementById('MDLBottomBtnPink').setAttribute("onclick", `finishCharacterCreation()`);
		clothStoreCategories = ed.categories;
		clothStoreCategoriesLength = ed.categoriesLength;
		document.getElementById("mainDivOutsideButtons").style.display = "flex";
		document.getElementById("MDLTopEffect").innerHTML=`
		<span style="font-family: 'Gilroy-UltraLight'; letter-spacing: 0.5vw; font-weight: 265; font-size: 0.8vw; margin-left: 0.9vw; margin-top: 2%;">${translations.character}</span>
		<h4 style="font-family: 'Gilroy-BlackItalic'; font-weight: 900; font-size: 1.4vw;">${translations.creator} ${translations.menu}</h4>
		<span style="font-family: 'Gilroy-RegularItalic'; font-weight: 400; color: rgba(255, 255, 255, 0.85); text-transform: capitalize; width: 55%; font-size: 0.7vw;">${translations.character_creator_description}</span>
		`;
		document.getElementById("mainDiv-Menu").style.display = "flex";
		document.getElementById("mainDivEffect").style.display = "flex";
		selectedPage2 = 1;
		generalData = ed.generalData;
		selectedComponentVariationData = {};
		// Face One
		selectedComponentVariationData["FaceOne"] = {};
		selectedComponentVariationData["FaceOne"].num = -1;
		// Skin One
		selectedComponentVariationData["SkinOne"] = {};
		selectedComponentVariationData["SkinOne"].num = -1;
		// Face Two
		selectedComponentVariationData["FaceTwo"] = {};
		selectedComponentVariationData["FaceTwo"].num = -1;
		// Skin Two
		selectedComponentVariationData["SkinTwo"] = {};
		selectedComponentVariationData["SkinTwo"].num = -1;
		// Face Three
		selectedComponentVariationData["FaceThree"] = {};
		selectedComponentVariationData["FaceThree"].num = -1;
		// Skin Three
		selectedComponentVariationData["SkinThree"] = {};
		selectedComponentVariationData["SkinThree"].num = -1;
		openCreateCharMenuWithoutReset(ed.gender);
		document.getElementById("pedDiv").style.display = "flex";
		document.getElementById("pedDiv2").style.display = "none";
		document.getElementById("pedDiv3").style.display = "none";
		document.getElementById("mainDivOutsideButtonDiv-ClothCompare").style.display = "none";
	} else if (ed.action === "setMaxNumForComponentVariation") {
		variationTexturesData[ed.action2].maxNum = ed.textureMaxNum;
	} else if (ed.action === "openClothStore") {
		currency = ed.currency;
		document.getElementById("MDLBottomBtnPink").innerHTML=`<span class="pay"></span><span style="margin-left: 2%;">(</span><span id="paymentSpan"></span><span>)</span>`;
		document.getElementById("paymentSpan").innerHTML=clothPayment + currency;
		document.getElementById('MDLBottomBtnPink').setAttribute("onclick", `openPaymentDialog()`);
		translations = ed.translations;
		currentPlayerSkin = ed.cps;
		clothMenuOpen = true;
		generalData = ed.generalData;
		shopType = ed.type;
		currentPedGender = ed.gender;
		clothStoreCategories = ed.categories;
		clothStoreCategoriesLength = ed.categoriesLength;
		document.getElementById("mainDivOutsideButtons").style.display = "flex";
		document.getElementById("MDLTopEffect").innerHTML=`
		<span style="font-family: 'Gilroy-UltraLight'; letter-spacing: 0.5vw; font-weight: 265; font-size: 0.8vw; margin-left: 0.9vw; margin-top: 2%;">${translations[ed.type]}</span>
		<h4 style="font-family: 'Gilroy-BlackItalic'; font-weight: 900; font-size: 1.4vw;">${translations.shop} ${translations.menu}</h4>
		<span style="font-family: 'Gilroy-RegularItalic'; font-weight: 400; color: rgba(255, 255, 255, 0.85); text-transform: capitalize; width: 55%; font-size: 0.7vw;">${translations.character_creator_description}</span>
		`;
		document.getElementById("mainDiv-Menu").style.display = "flex";
		document.getElementById("mainDivEffect").style.display = "flex";
		selectedPage2 = 1;
		openClothStore();
		if (ed.enableCompare) {
			document.getElementById("mainDivOutsideButtonDiv-ClothCompare").style.display = "flex";
		} else {
			document.getElementById("mainDivOutsideButtonDiv-ClothCompare").style.display = "none";
		}
		document.getElementById("pedDiv").style.display = "flex";
		document.getElementById("pedDiv2").style.display = "none";
		document.getElementById("pedDiv3").style.display = "none";
	} else if (ed.action === "setTattooList") {
		tattoosData = ed.list;
		currentPlayerTattoos = ed.tattoos;
		currentPlayerTattoos2 = ed.tattoos.map(tattoo => ({ ...tattoo }));
	} else if (ed.action === "closeAll") {
		clothMenuOpen = false;
		creatingChar = false;
		document.getElementById("mainDivOutsideButtons").style.display = "none";
		document.getElementById("mouseInfosDiv").style.display = "none";
		showMouseInfosState = false;
		closeDialog();
		menuOpen = false;
		document.getElementById("mainDiv-Menu").style.display = "none";
		document.getElementById("mainDivEffect").style.display = "none";
		generalData.forEach(function(data, index) {
			if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}`)) {
				document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}`).innerHTML="";
			}
		});
		generalData = {};
		variationsData = {};
		variationTexturesData = {};
		selectedComponentVariationData = {};
	}
	document.onkeyup = function(data) {
		if (data.which == 27 && enableCompareState) {
			document.getElementById("mainDivOutsideButton-ClothCompareConfirm").classList.remove("mainDivOutsideButtonActive");
			post({action: "stopComparingClothes"});
			savedClothData[1] = null;
			document.getElementById("mainDivOutsideButton-ClothCompare1").classList.remove("mainDivOutsideButtonActive");
			savedClothData[2] = null;
			document.getElementById("mainDivOutsideButton-ClothCompare2").classList.remove("mainDivOutsideButtonActive");
			document.getElementById("pedDiv").style.display = "flex";
			document.getElementById("pedDiv2").style.display = "none";
			document.getElementById("pedDiv3").style.display = "none";
			document.getElementById("mainDiv-Menu").style.display = "flex";
			document.getElementById("mainDivOutsideButtons").style.display = "flex";
			$("#animPosInfoDiv").css({bottom: "2%", position:'absolute', display: 'flex'}).animate({bottom: "-10%"}, 400, function() {
				$("#animPosInfoDiv").fadeOut();
			});
			choosedPed = null;
			enableCompareState = false;
			clothMenuOpen = false;
			setTimeout(() => {
				clothMenuOpen = true;
			}, 2500);
			return
		}
		if (data.which == 13 && enableCompareState && choosedPed) {
			post({action: "choosePed2", num: choosedPed});
			wearClothes(savedClothData[choosedPed]);
			document.getElementById("mainDivOutsideButton-ClothCompareConfirm").classList.remove("mainDivOutsideButtonActive");
			post({action: "stopComparingClothes"});
			savedClothData[1] = null;
			document.getElementById("mainDivOutsideButton-ClothCompare1").classList.remove("mainDivOutsideButtonActive");
			savedClothData[2] = null;
			document.getElementById("mainDivOutsideButton-ClothCompare2").classList.remove("mainDivOutsideButtonActive");
			document.getElementById("pedDiv").style.display = "flex";
			document.getElementById("pedDiv2").style.display = "none";
			document.getElementById("pedDiv3").style.display = "none";
			document.getElementById("mainDiv-Menu").style.display = "flex";
			document.getElementById("mainDivOutsideButtons").style.display = "flex";
			$("#animPosInfoDiv").css({bottom: "2%", position:'absolute', display: 'flex'}).animate({bottom: "-10%"}, 400, function() {
				$("#animPosInfoDiv").fadeOut();
			});
			choosedPed = null;
			enableCompareState = false;
			clothMenuOpen = false;
			setTimeout(() => {
				clothMenuOpen = true;
			}, 2500);
			return
		}
		if (data.which == 27 && clothMenuOpen) {
			dialogOpen = true;
			document.getElementById("mainDivDialog").style.display = "flex";
			// document.getElementById("mainDivDialogBG").style.display = "flex";
			// document.getElementById("MDLCenter").style.filter = "blur(5px)";
			document.getElementById("mainDivDialogSpan").innerHTML=`${translations.confirm_payment} ${currency}${clothPayment}.`;
			document.getElementById("mainDivDialogButtons").innerHTML=`
			<div class="mainDivDialogButtonGreen" onclick="buyClothing('cash')">${translations.cash} (${currency}${clothPayment})</div>
			<div class="mainDivDialogButtonGreen" onclick="buyClothing('bank')">${translations.bank} (${currency}${clothPayment})</div>
			<div class="mainDivDialogButtonRed" onclick="discardCharacterCreation()">${translations.discard}</div>
			<div class="mainDivDialogButtonRed" onclick="closeDialog()">${translations.cancel}</div>
			`;
			return
		}
		if (data.which == 27 && creatingChar) {
			finishCharacterCreation();
			return
		}
		if (data.which == 27 && dialogOpen) {
			closeDialog();
		}
		if (data.which == 37 && clothMenuOpen || creatingChar) {
			post({action: 'updateRotation', rotationDelta: -30.5})
		}
		if (data.which == 39 && clothMenuOpen || creatingChar) {
			post({action: 'updateRotation', rotationDelta: 30.5})
		}
		if (data.which == 38 && clothMenuOpen || creatingChar) {
			post({action: 'updateZoom', type: "zoomOut"})
		}
		if (data.which == 40 && clothMenuOpen || creatingChar) {
			post({action: 'updateZoom', type: "zoomIn"})
		}
	}
});

function finalizeCharacter() {
	post({action: "finalizeCharacter"});
	document.getElementById("mainDivOutsideButtons").style.display = "none";
	document.getElementById("mouseInfosDiv").style.display = "none";
	showMouseInfosState = false;
	closeDialog();
	menuOpen = false;
	document.getElementById("mainDiv-Menu").style.display = "none";
	document.getElementById("mainDivEffect").style.display = "none";
	creatingChar = false;
	generalData.forEach(function(data, index) {
		if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}`)) {
			document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}`).innerHTML="";
		}
	});
	generalData = {};
	variationsData = {};
	variationTexturesData = {};
	selectedComponentVariationData = {};
}

function discardCharacterCreation() {
	if (clothMenuOpen) {
		post({action: "cancelBeforePayment"});
		clothPayment = 0;
		basketData = {};
		if (enableCompareState) {
			enableCompareState = false;
			document.getElementById("mainDivOutsideButton-ClothCompareConfirm").classList.remove("mainDivOutsideButtonActive");
			post({action: "stopComparingClothes"});
			savedClothData[1] = null;
			document.getElementById("mainDivOutsideButton-ClothCompare1").classList.remove("mainDivOutsideButtonActive");
			savedClothData[2] = null;
			document.getElementById("mainDivOutsideButton-ClothCompare2").classList.remove("mainDivOutsideButtonActive");
			document.getElementById("pedDiv").style.display = "flex";
			document.getElementById("pedDiv2").style.display = "none";
			document.getElementById("pedDiv3").style.display = "none";
			document.getElementById("mainDiv-Menu").style.display = "flex";
			document.getElementById("mainDivOutsideButtons").style.display = "flex";
			$("#animPosInfoDiv").css({bottom: "2%", position:'absolute', display: 'flex'}).animate({bottom: "-10%"}, 400, function() {
				$("#animPosInfoDiv").fadeOut();
			});
			choosedPed = null;
			clothMenuOpen = false;
			setTimeout(() => {
				clothMenuOpen = true;
			}, 2500);
		}
	} else {
		post({action: "finalizeCharacter", type: "discard"});
	}
	clothMenuOpen = false;
	creatingChar = false;
	document.getElementById("mainDivOutsideButtons").style.display = "none";
	document.getElementById("mouseInfosDiv").style.display = "none";
	showMouseInfosState = false;
	closeDialog();
	menuOpen = false;
	document.getElementById("mainDiv-Menu").style.display = "none";
	document.getElementById("mainDivEffect").style.display = "none";
	generalData = {};
	variationsData = {};
	variationTexturesData = {};
	selectedComponentVariationData = {};
}

function buyClothing(type) {
	generalData.forEach(function(data, index) {
		if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}`)) {
			document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}`).innerHTML="";
		}
	});
	if (enableCompareState) {
		enableCompareState = false;
		document.getElementById("mainDivOutsideButton-ClothCompareConfirm").classList.remove("mainDivOutsideButtonActive");
		post({action: "stopComparingClothes"});
		savedClothData[1] = null;
		document.getElementById("mainDivOutsideButton-ClothCompare1").classList.remove("mainDivOutsideButtonActive");
		savedClothData[2] = null;
		document.getElementById("mainDivOutsideButton-ClothCompare2").classList.remove("mainDivOutsideButtonActive");
		document.getElementById("pedDiv").style.display = "flex";
		document.getElementById("pedDiv2").style.display = "none";
		document.getElementById("pedDiv3").style.display = "none";
		document.getElementById("mainDiv-Menu").style.display = "flex";
		document.getElementById("mainDivOutsideButtons").style.display = "flex";
		$("#animPosInfoDiv").css({bottom: "2%", position:'absolute', display: 'flex'}).animate({bottom: "-10%"}, 400, function() {
			$("#animPosInfoDiv").fadeOut();
		});
		choosedPed = null;
		clothMenuOpen = false;
		setTimeout(() => {
			clothMenuOpen = true;
		}, 2500);
	}
	generalData = {};
	variationsData = {};
	variationTexturesData = {};
	selectedComponentVariationData = {};
	clothMenuOpen = false;
	post({action: "buyClothing", type: type, amount: clothPayment}, function(cbData) {
		if (cbData === true) {
			post({action: "paidCloth"});
		}
	});
	clothPayment = 0;
	basketData = {};
	document.getElementById("paymentSpan").innerHTML=clothPayment + currency;
	// document.getElementById("paymentSpan2").innerHTML=clothPayment + currency;
	closeDialog();
	menuOpen = false;
	document.getElementById("mainDivOutsideButtons").style.display = "none";
	document.getElementById("mouseInfosDiv").style.display = "none";
	showMouseInfosState = false;
	document.getElementById("mainDiv-Menu").style.display = "none";
	document.getElementById("mainDivEffect").style.display = "none";
}

function openPaymentDialog() {
	dialogOpen = true;
	// document.getElementById("MDLCenter").style.filter = "blur(5px)";
	document.getElementById("mainDivDialog").style.display = "flex";
	// document.getElementById("mainDivDialogBG").style.display = "flex";
	document.getElementById("mainDivDialogSpan").innerHTML=`${translations.confirm_payment} ${currency}${clothPayment}.`;
	document.getElementById("mainDivDialogButtons").innerHTML=`
	<div class="mainDivDialogButtonGreen" onclick="buyClothing('cash')">${translations.cash} (${currency}${clothPayment})</div>
	<div class="mainDivDialogButtonGreen" onclick="buyClothing('bank')">${translations.bank} (${currency}${clothPayment})</div>
	<div class="mainDivDialogButtonRed" onclick="discardCharacterCreation()">${translations.discard}</div>
	<div class="mainDivDialogButtonRed" onclick="closeDialog()">${translations.cancel}</div>
	`;
}

function closeDialog() {
	dialogOpen = false;
	document.getElementById("mainDivDialog").style.display = "none";
	// document.getElementById("mainDivDialogBG").style.display = "none";
	document.getElementById("MDLCenter").style.filter = "none";
}

expandData = [];
function expandDiv(element) {
	const heightData = {
		["MalePeds"]: {height: "44vh"},
		["FemalePeds"]: {height: "44vh"},
		["FaceOne"]: {height: "82vh"},
		["SkinOne"]: {height: "82vh"},
		["FaceTwo"]: {height: "82vh"},
		["SkinTwo"]: {height: "82vh"},
		["FaceThree"]: {height: "82vh"},
		["SkinThree"]: {height: "82vh"},
		["EyeColor"]: {height: "44vh"},
		["Eyebrows"]: {height: "44vh" },
		["EyebrowColors"]: {height: "44vh"},
		["FacialHairs"]: {height: "44vh"},
		["Hairs"]: {height: "44vh"},
		["Blemishes"]: {height: "44vh"},
		["Ageing"]: {height: "44vh"},
		["Complexion"]: {height: "44vh"},
		["SunDamage"]: {height: "44vh"},
		["MolesFreckles"]: {height: "44vh"},
		["ChestHair"]: {height: "44vh"},
		["BodyBlemishes"]: {height: "44vh"},
		["AddBodyBlemishes"]: {height: "44vh"},
		["Makeup"]: {height: "44vh"},
		["Blush"]: {height: "44vh"},
		["Lipstick"]: {height: "44vh"},
		["Jacket"]: {height: "44vh"},
		["Undershirt"]: {height: "44vh"},
		["Arms/Gloves"]: {height: "44vh"},
		["Pants"]: {height: "44vh"},
		["Shoes"]: {height: "44vh"},
		["Masks"]: {height: "44vh"},
		["Scarfs/Necklaces"]: {height: "44vh"},
		["Vest"]: {height: "44vh"},
		["Hat"]: {height: "44vh"},
		["Glasses"]: {height: "44vh"},
		["Decals"]: {height: "44vh"},
		["Earrings"]: {height: "44vh"},
		["Watches"]: {height: "44vh"},
		["Bracelets"]: {height: "44vh"},
		["Bag"]: {height: "44vh"},
		["Tattoo"]: {height: "64.5vh"}
	};
	if (document.getElementById(element)) {
		let newElement = element.replace("mainDivBottomLeftBottomDivBottom-", "");
		if (expandData[newElement] === true) {
			expandData[newElement] = null;
			if (document.getElementById(element)) {
				document.getElementById(element).scrollTop = 0;
			}
			if (document.getElementById(`mainDivBottomLeftBottomDivTopExpandDivButton-${newElement}`)) {
				document.getElementById(`mainDivBottomLeftBottomDivTopExpandDivButton-${newElement}`).innerHTML=`<i class="fa-solid fa-chevron-down" style="color: rgba(255, 255, 255, 0.75); opacity: 0.73; margin-top: 19.4%;"></i>`;
			}
			document.getElementById(element).style.maxHeight = heightData[newElement].maxHeight || "10.6vh";
		} else {
			expandData[newElement] = true;
			if (document.getElementById(element)) {
				document.getElementById(element).scrollTop = 0;
			}
			if (document.getElementById(`mainDivBottomLeftBottomDivTopExpandDivButton-${newElement}`)) {
				document.getElementById(`mainDivBottomLeftBottomDivTopExpandDivButton-${newElement}`).innerHTML=`<i class="fa-solid fa-chevron-up" style="color: rgba(255, 255, 255, 0.75); opacity: 0.73; margin-top: 19.4%;"></i>`;
			}
			if (heightData[newElement]) {
				document.getElementById(element).style.maxHeight = heightData[newElement].height;
			} else {
				document.getElementById(element).style.maxHeight = "38vh";
			}
		}
	}
}

function expandDiv2(element) {
	if (element.includes("mainDivBottomLeftBottomDivTopExpandDivButton-")) {
		element = element.replace("mainDivBottomLeftBottomDivTopExpandDivButton-", "");
	}
	if (expandData[element]) {
		expandData[element] = null;
		document.getElementById(`MDLCDivBottom-${element}`).style.display = "none";
		if (document.getElementById(`mainDivBottomLeftBottomDivTopExpandDivButton-${element}`)) {
			document.getElementById(`mainDivBottomLeftBottomDivTopExpandDivButton-${element}`).innerHTML=`<i class="fa-solid fa-chevron-down" style="color: rgba(255, 255, 255, 0.75); opacity: 0.73; margin-top: 19.4%;"></i>`;
		}
	} else {
		expandData[element] = true;
		document.getElementById(`MDLCDivBottom-${element}`).style.display = "flex";
		if (document.getElementById(`mainDivBottomLeftBottomDivTopExpandDivButton-${element}`)) {
			document.getElementById(`mainDivBottomLeftBottomDivTopExpandDivButton-${element}`).innerHTML=`<i class="fa-solid fa-chevron-up" style="color: rgba(255, 255, 255, 0.75); opacity: 0.73; margin-top: 19.4%;"></i>`;
		}
	}
}

function nextPage2() {
	if (clothMenuOpen || creatingChar) {
		if (shopType === "barber" || shopType === "clothing") {
			if (selectedPage2 < clothStoreCategoriesLength) {
				selectedPage2 = selectedPage2 + 1;
				generalData.forEach(function(data, index) {
					let display = "flex";
					if (!clothStoreCategories[data.action + "_" + selectedPage2]) display = "none";
					if (!document.getElementById(`MDLCDiv-${data.action}`)) return
					document.getElementById(`MDLCDiv-${data.action}`).style.display = display;
				});
			}
		} else if (shopType === "charcreation") {
			if (selectedPage2 < clothStoreCategoriesLength) {
				selectedPage2 = selectedPage2 + 1;
				if ((selectedPage2 === 2 || selectedPage2 === 3 || selectedPage2 === 4) && selectedPed !== "mp_m_freemode_01" && selectedPed !== "mp_f_freemode_01") {
					nextPage2();
				}
				generalData.forEach(function(data, index) {
					let display = "flex";
					if (!clothStoreCategories[data.action + "_" + selectedPage2]) display = "none";
					if (!document.getElementById(`MDLCDiv-${data.action}`)) return;
					document.getElementById(`MDLCDiv-${data.action}`).style.display = display;
				});
			}
		} else if (shopType === "tattoo") {
			if (selectedPage2 === 1) {
				selectedPage2 = 2;
				showTattooPage('Torso');
			} else if (selectedPage2 === 2) {
				selectedPage2 = 3;
				showTattooPage('LeftArm');
			} else if (selectedPage2 === 3) {
				selectedPage2 = 4;
				showTattooPage('RightArm');
			} else if (selectedPage2 === 4) {
				selectedPage2 = 5;
				showTattooPage('LeftLeg');
			} else if (selectedPage2 === 5) {
				selectedPage2 = 6;
				showTattooPage('RightLeg');
			} else if (selectedPage2 === 6) {
				selectedPage2 = 1;
				showTattooPage('Head');
			}
		}
	}
}

function goBack2() {
	if (clothMenuOpen || creatingChar) {
		if (shopType === "barber" || shopType === "clothing") {
			if (selectedPage2 <= clothStoreCategoriesLength && selectedPage2 > 1) {
				selectedPage2 = selectedPage2 - 1;
				generalData.forEach(function(data, index) {
					let display = "flex";
					if (!clothStoreCategories[data.action + "_" + selectedPage2]) display = "none";
					if (!document.getElementById(`MDLCDiv-${data.action}`)) return
					document.getElementById(`MDLCDiv-${data.action}`).style.display = display;
				});
			}
		} else if (shopType === "charcreation") {
			if (selectedPage2 <= clothStoreCategoriesLength && selectedPage2 > 1) {
				selectedPage2 = selectedPage2 - 1;
				if ((selectedPage2 === 2 || selectedPage2 === 3 || selectedPage2 === 4) && selectedPed !== "mp_m_freemode_01" && selectedPed !== "mp_f_freemode_01") {
					goBack2();
				}
				generalData.forEach(function(data, index) {
					let display = "flex";
					if (!clothStoreCategories[data.action + "_" + selectedPage2]) display = "none";
					if (!document.getElementById(`MDLCDiv-${data.action}`)) return
					document.getElementById(`MDLCDiv-${data.action}`).style.display = display;
				});
			}
		} else if (shopType === "tattoo") {
			if (selectedPage2 === 1) {
				selectedPage2 = 6;
				showTattooPage('RightLeg');
			} else if (selectedPage2 === 2) {
				selectedPage2 = 1;
				showTattooPage('Head');
			} else if (selectedPage2 === 3) {
				selectedPage2 = 2;
				showTattooPage('Torso');
			} else if (selectedPage2 === 4) {
				selectedPage2 = 3;
				showTattooPage('LeftArm');
			} else if (selectedPage2 === 5) {
				selectedPage2 = 4;
				showTattooPage('RightArm');
			} else if (selectedPage2 === 6) {
				selectedPage2 = 5;
				showTattooPage('LeftLeg');
			}
		}
	}
}

function changeVariation(variationNumber, num, action, texture) {
	if (num === undefined) return;
	closeDialog();
	if (selectedComponentVariationData[action] && selectedComponentVariationData[action].num !== undefined) {
		if (document.getElementById(`MDLCDivBDiv-${action}-${selectedComponentVariationData[action].num}`)) {
			const divElement = document.getElementById(`MDLCDivBDiv-${action}-${selectedComponentVariationData[action].num}`);
			const classes = divElement.className.split(" ");
			const foundClass = classes.find(word => word.includes("IMGSelected") || word.includes("IMG2Selected") || word.includes("IMG3Selected") || word.includes("IMGMaskSelected"));
			if (foundClass) {
				const newClass = foundClass.replace("Selected", "");
				divElement.classList.remove(foundClass);
				divElement.classList.add(newClass);
			}
			divElement.classList.remove("MDLCDivBDivSelected");
		}
	}
	selectedComponentVariationData[action] = {};
	selectedComponentVariationData[action].num = Number(num);
	if (document.getElementById(`MDLCDivBDiv-${action}-${num}`)) {
		const divElement = document.getElementById(`MDLCDivBDiv-${action}-${num}`);
		const classes = divElement.className.split(" ");
		const foundClass = classes.find(word => word.includes("IMG"));
		document.getElementById(`MDLCDivBDiv-${action}-${num}`).classList.remove(foundClass);
		document.getElementById(`MDLCDivBDiv-${action}-${num}`).classList.add(foundClass + "Selected");
		document.getElementById(`MDLCDivBDiv-${action}-${num}`).classList.add("MDLCDivBDivSelected");
	}
	variationsData[action] = Number(num);
	variationTexturesData[action].currentNum = 0;
	variationTexturesData[action + "_2"].currentNum = 0;
	if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${action}Span-ComponentVariation`)) {
		document.getElementById(`mainDivBottomLeftBottomDivBottom-${action}Span-ComponentVariation`).innerHTML=variationsData[action];
	}
	if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${action}Span-TextureVariation`)) {
		document.getElementById(`mainDivBottomLeftBottomDivBottom-${action}Span-TextureVariation`).innerHTML=variationTexturesData[action].currentNum;
	}
	if (action === "Blemishes" || action === "Ageing" || action === "Complexion" || action === "SunDamage" || action === "MolesFreckles" || action === "ChestHair" || action === "BodyBlemishes" || action === "AddBodyBlemishes" || action === "Makeup" || action === "Blush" || action === "Lipstick" || action === "FacialHairs" || action === "Eyebrows") {
		let opacity = 1.0;
		if (document.getElementById(`${action}-OpacitySlider`)) {
			opacity = document.getElementById(`${action}-OpacitySlider`).value;
		}
		post({action: "changeHeadOverlay", action2: action, num1: Number(variationNumber), num2: selectedComponentVariationData[action].num, num3: variationTexturesData[action].currentNum, num4: variationTexturesData[action + "_2"].currentNum, opacity: opacity});
		if (clothMenuOpen && currentPlayerSkin) {
			if (currentPlayerSkin[action]) {
				if (action === "Glasses") {
					if (currentPlayerSkin[action].currentItemNum === -1) {
						currentPlayerSkin[action].currentItemNum = 0;
					}
				}
				if (!basketData[action]) {
					if (Number(num) !== currentPlayerSkin[action].currentItemNum) {
						basketData[action] = true;
						let money = currentPlayerSkin[action].Default;
						if (currentPlayerSkin[action].Customs && currentPlayerSkin[action].Customs[Number(num)]) {
							money = currentPlayerSkin[action].Customs[Number(num)];
						}
						clothPayment = clothPayment + money;
						document.getElementById("paymentSpan").innerHTML=clothPayment + currency;
					}
				} else {
					if (Number(num) === currentPlayerSkin[action].currentItemNum) {
						basketData[action] = null;
						let money = currentPlayerSkin[action].Default;
						if (currentPlayerSkin[action].Customs && currentPlayerSkin[action].Customs[Number(num)]) {
							money = currentPlayerSkin[action].Customs[Number(num)];
						}
						clothPayment = clothPayment - money;
						document.getElementById("paymentSpan").innerHTML=clothPayment + currency;
					}
				}
			}
		}
		return
	}
	texture = texture || 0;
	post({action: "changeVariation", action2: action, num1: Number(variationNumber), num2: Number(num), num3: texture});
	if (clothMenuOpen && currentPlayerSkin) {
		if (currentPlayerSkin[action]) {
			if (action === "Glasses") {
				if (currentPlayerSkin[action].currentItemNum === -1) {
					currentPlayerSkin[action].currentItemNum = 0;
				}
			}
			if (!basketData[action]) {
				if (Number(num) !== currentPlayerSkin[action].currentItemNum) {
					basketData[action] = true;
					let money = currentPlayerSkin[action].Default;
					if (currentPlayerSkin[action].Customs && currentPlayerSkin[action].Customs[Number(num)]) {
						money = currentPlayerSkin[action].Customs[Number(num)];
					}
					clothPayment = clothPayment + money;
					document.getElementById("paymentSpan").innerHTML=clothPayment + currency;
				}
			} else {
				if (Number(num) === currentPlayerSkin[action].currentItemNum) {
					basketData[action] = null;
					let money = currentPlayerSkin[action].Default;
					if (currentPlayerSkin[action].Customs && currentPlayerSkin[action].Customs[Number(num)]) {
						money = currentPlayerSkin[action].Customs[Number(num)];
					}
					clothPayment = clothPayment - money;
					document.getElementById("paymentSpan").innerHTML=clothPayment + currency;
				}
			}
		}
	}
}

function changePropVariation(variationNumber, num, action) {
	closeDialog();
	if (selectedComponentVariationData[action] && selectedComponentVariationData[action].num !== undefined) {
		if (document.getElementById(`MDLCDivBDiv-${action}-${selectedComponentVariationData[action].num}`)) {
			document.getElementById(`MDLCDivBDiv-${action}-${selectedComponentVariationData[action].num}`).classList.remove("MDLCDivBDivSelected")
		}
	}
	selectedComponentVariationData[action] = {};
	selectedComponentVariationData[action].num = Number(num);
	if (document.getElementById(`MDLCDivBDiv-${action}-${num}`)) {
		document.getElementById(`MDLCDivBDiv-${action}-${num}`).classList.add("MDLCDivBDivSelected")
	}
	variationsData[action] = Number(num);
	variationTexturesData[action].currentNum = 0;
	variationTexturesData[action + "_2"].currentNum = 0;
	if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${action}Span-ComponentVariation`)) {
		document.getElementById(`mainDivBottomLeftBottomDivBottom-${action}Span-ComponentVariation`).innerHTML=variationsData[action];
	}
	if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${action}Span-TextureVariation`)) {
		document.getElementById(`mainDivBottomLeftBottomDivBottom-${action}Span-TextureVariation`).innerHTML=variationTexturesData[action].currentNum;
	}
	post({action: "changePropVariation", action2: action, num1: Number(variationNumber), num2: Number(num), num3: 0});
	if (clothMenuOpen && currentPlayerSkin) {
		if (currentPlayerSkin[action]) {
			if (action === "Glasses") {
				if (currentPlayerSkin[action].currentItemNum === -1) {
					currentPlayerSkin[action].currentItemNum = 0;
				}
			}
			if (!basketData[action]) {
				if (Number(num) !== currentPlayerSkin[action].currentItemNum) {
					basketData[action] = true;
					clothPayment = clothPayment + currentPlayerSkin[action].Default;
					document.getElementById("paymentSpan").innerHTML=clothPayment + currency;
					// document.getElementById("paymentSpan2").innerHTML=clothPayment + currency;
				}
			} else {
				if (Number(num) === currentPlayerSkin[action].currentItemNum) {
					basketData[action] = null;
					clothPayment = clothPayment - currentPlayerSkin[action].Default;
					document.getElementById("paymentSpan").innerHTML=clothPayment + currency;
					// document.getElementById("paymentSpan2").innerHTML=clothPayment + currency;
				}
			}
		}
	}
}

function changeTextureVariation(variationNumber, num, action) {
	closeDialog();
	if (variationNumber === undefined || num === undefined || action === undefined) return;
	if (!variationTexturesData[action]) {variationTexturesData[action] = {}};
	variationTexturesData[action].currentNum = Number(num);
	if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${action}Span-TextureVariation`)) {
		document.getElementById(`mainDivBottomLeftBottomDivBottom-${action}Span-TextureVariation`).innerHTML=variationTexturesData[action].currentNum;
	}
	if (action === "Blemishes" || action === "Ageing" || action === "Complexion" || action === "SunDamage" || action === "MolesFreckles" || action === "ChestHair" || action === "BodyBlemishes" || action === "AddBodyBlemishes" || action === "Makeup" || action === "Blush" || action === "Lipstick" || action === "FacialHairs" || action === "Eyebrows") {
		let opacity = 1.0;
		if (document.getElementById(`${action}-OpacitySlider`)) {
			opacity = document.getElementById(`${action}-OpacitySlider`).value;
		}
		post({action: "changeHeadOverlay", action2: action, num1: Number(variationNumber), num2: selectedComponentVariationData[action].num, num3: variationTexturesData[action].currentNum, num4: variationTexturesData[action + "_2"].currentNum, opacity: opacity});
		return
	}
	post({action: "changeVariation", action2: action, num1: Number(variationNumber), num2: variationsData[action], num3: Number(num)});
}

function changeVariationColor(action, num) {
	closeDialog();
	let textureData = {
		["FirstMakeupColor"]: {action: "Makeup", variationNumber: 4},
		["SecondMakeupColor"]: {action: "Makeup", second: true, variationNumber: 7},
		["FirstBlushColor"]: {action: "Blush", variationNumber: 5},
		["SecondBlushColor"]: {action: "Blush", second: true, variationNumber: 5},
		["FirstLipstickColor"]: {action: "Lipstick", variationNumber: 8},
		["SecondLipstickColor"]: {action: "Lipstick", second: true, variationNumber: 8},
		["EyebrowColors"]: {action: "Eyebrows", variationNumber: 2},
		["EyebrowHighlightColors"]: {action: "Eyebrows", second: true, variationNumber: 2},
		["FacialHairsColors"]: {action: "FacialHairs", variationNumber: 1},
		["FacialHairsHighlightColors"]: {action: "FacialHairs", second: true, variationNumber: 1},
		["HairsColors"]: {action: "Hairs", variationNumber: -1},
		["HairsHighlightColors"]: {action: "Hairs", second: true, variationNumber: -1}
	};
	let newAction = textureData[action].action;
	let opacity = document.getElementById(`${newAction}-OpacitySlider`) && document.getElementById(`${newAction}-OpacitySlider`).value || 1.0;
	if (textureData[action] && textureData[action].second === true) {
		variationTexturesData[newAction + "_2"].currentNum = Number(num) + 1;
		post({action: "changeHeadOverlay", action2: newAction, num1: textureData[action].variationNumber, num2: selectedComponentVariationData[newAction].num, num3: variationTexturesData[newAction].currentNum, num4: variationTexturesData[newAction + "_2"].currentNum, opacity: opacity});
		return
	}
	variationTexturesData[newAction].currentNum = Number(num) + 1;
	post({action: "changeHeadOverlay", action2: newAction, num1: textureData[action].variationNumber, num2: selectedComponentVariationData[newAction].num, num3: variationTexturesData[newAction].currentNum, num4: variationTexturesData[newAction + "_2"].currentNum, opacity: opacity});
}

function changeFace(action, num) {
	closeDialog();
	//if (selectedComponentVariationData[action] && selectedComponentVariationData[action].num) {
		if (document.getElementById(`MDLCDivBDiv-${action}-${selectedComponentVariationData[action].num}`)) {
			document.getElementById(`MDLCDivBDiv-${action}-${selectedComponentVariationData[action].num}`).classList.remove("MDLCDivBDivSelected")
		}
	//}
	selectedComponentVariationData[action].num = Number(num);
	if (document.getElementById(`MDLCDivBDiv-${action}-${selectedComponentVariationData[action].num}`)) {
		document.getElementById(`MDLCDivBDiv-${action}-${selectedComponentVariationData[action].num}`).classList.add("MDLCDivBDivSelected")
	}
	post({
		action: "changeFace",
		firstShape: selectedComponentVariationData["FaceOne"].num,
		secondShape: selectedComponentVariationData["FaceTwo"].num,
		thirdShape: selectedComponentVariationData["FaceThree"].num,
		firstSkin: selectedComponentVariationData["SkinOne"].num,
		secondSkin: selectedComponentVariationData["SkinTwo"].num,
		thirdSkin: selectedComponentVariationData["SkinThree"].num,
		shapeMix: document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-FaceMix").value,
		skinMix: document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-SkinMix").value,
		thirdMix: document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-ThirdMix").value,
	});
}

function setPedEyeColor(action, num) {
	closeDialog();
	if (selectedComponentVariationData[action] && selectedComponentVariationData[action].num !== undefined) {
		if (document.getElementById(`MDLCDivBDiv-${action}-${selectedComponentVariationData[action].num}`)) {
			const divElement = document.getElementById(`MDLCDivBDiv-${action}-${selectedComponentVariationData[action].num}`);
			const classes = divElement.className.split(" ");
			const foundClass = classes.find(word => word.includes("IMGSelected") || word.includes("IMG2Selected") || word.includes("IMG3Selected"));
			if (foundClass) {
				const newClass = foundClass.replace("Selected", "");
				divElement.classList.remove(foundClass);
				divElement.classList.add(newClass);
			}
			divElement.classList.remove("MDLCDivBDivSelected");
		}
	}
	selectedComponentVariationData[action] = {};
	selectedComponentVariationData[action].num = Number(num);
	if (document.getElementById(`MDLCDivBDiv-${action}-${num}`)) {
		const divElement = document.getElementById(`MDLCDivBDiv-${action}-${num}`);
		const classes = divElement.className.split(" ");
		const foundClass = classes.find(word => word.includes("IMG"));
		document.getElementById(`MDLCDivBDiv-${action}-${num}`).classList.remove(foundClass);
		document.getElementById(`MDLCDivBDiv-${action}-${num}`).classList.add(foundClass + "Selected");
		document.getElementById(`MDLCDivBDiv-${action}-${num}`).classList.add("MDLCDivBDivSelected");
	}
	post({action: "setPedEyeColor", action2: action, num1: Number(num)});
}

function appendHtml(el, str) {
	var div = document.createElement('div');
	div.innerHTML = str;
	while (div.children.length > 0) {
		el.appendChild(div.children[0]);
	}
}

let isMouseDown = false;
window.addEventListener('mousedown', function(event) {
	if (event.button === 0) {
		if (checkIsInPedDiv(event) || checkIsInPedDiv2(event) || checkIsInPedDiv3(event)) {
			isMouseDown = true;
		}
	}
});

window.addEventListener('mouseup', function(event) {
	if (event.button === 0) {
		if (checkIsInPedDiv(event) || checkIsInPedDiv2(event) || checkIsInPedDiv3(event)) {
			isMouseDown = false;
		}
	}
});

window.addEventListener('mousemove', function(event) {
	if (isMouseDown && checkIsInPedDiv(event)) {
		const deltaX = event.movementX || event.mozMovementX || event.webkitMovementX || 0;
		if (deltaX !== 0) {
			post({action: "updateRotation", rotationDelta: deltaX});
		}
	}
	if (isMouseDown && checkIsInPedDiv2(event)) {
		const deltaX = event.movementX || event.mozMovementX || event.webkitMovementX || 0;
		if (deltaX !== 0) {
			post({action: "updateRotation2", num: 1, rotationDelta: deltaX});
		}
	}
	if (isMouseDown && checkIsInPedDiv3(event)) {
		const deltaX = event.movementX || event.mozMovementX || event.webkitMovementX || 0;
		if (deltaX !== 0) {
			post({action: "updateRotation2", num: 2, rotationDelta: deltaX});
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

function checkIsInPedDiv2(event) {
	const pedDiv = document.getElementById('pedDiv2');
	const rect = pedDiv.getBoundingClientRect();
	const isInDiv = (
		event.clientX >= rect.left &&
		event.clientX <= rect.right &&
		event.clientY >= rect.top &&
		event.clientY <= rect.bottom
	);
	return isInDiv
}

function checkIsInPedDiv3(event) {
	const pedDiv = document.getElementById('pedDiv3');
	const rect = pedDiv.getBoundingClientRect();
	const isInDiv = (
		event.clientX >= rect.left &&
		event.clientX <= rect.right &&
		event.clientY >= rect.top &&
		event.clientY <= rect.bottom
	);
	return isInDiv
}

const pedDiv2 = document.getElementById('pedDiv2');
pedDiv2.addEventListener('mouseenter', () => {
	post({action: "hoverPed", state: true, num: 1});
});

pedDiv2.addEventListener('mouseleave', () => {
	if (choosedPed == 1) return;
	post({action: "hoverPed", state: false, num: 1});
});

pedDiv2.addEventListener('click', () => {
	choosedPed = 1;
	post({action: "choosePed", num: 1});
});

const pedDiv3 = document.getElementById('pedDiv3');
pedDiv3.addEventListener('mouseenter', () => {
	post({action: "hoverPed", state: true, num: 2});
});

pedDiv3.addEventListener('mouseleave', () => {
	if (choosedPed == 2) return;
	post({action: "hoverPed", state: false, num: 2});
});

pedDiv3.addEventListener('click', () => {
	choosedPed = 2;
	post({action: "choosePed", num: 2});
});

// document.addEventListener('DOMContentLoaded', () => {
// 	// Face Mixers
// 	document.getElementById(`mainDivBottomLeftBottomDivBottomInputSlider-FaceMix`).addEventListener('input', function() {
// 		post({
// 			action: "changeFace",
// 			firstShape: selectedComponentVariationData["FaceOne"].num,
// 			secondShape: selectedComponentVariationData["FaceTwo"].num,
// 			thirdShape: selectedComponentVariationData["FaceThree"].num,
// 			firstSkin: selectedComponentVariationData["SkinOne"].num,
// 			secondSkin: selectedComponentVariationData["SkinTwo"].num,
// 			thirdSkin: selectedComponentVariationData["SkinThree"].num,
// 			shapeMix: document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-FaceMix").value,
// 			skinMix: document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-SkinMix").value,
// 			thirdMix: document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-ThirdMix").value,
// 		});
// 	});
// 	document.getElementById(`mainDivBottomLeftBottomDivBottomInputSlider-SkinMix`).addEventListener('input', function() {
// 		post({
// 			action: "changeFace",
// 			firstShape: selectedComponentVariationData["FaceOne"].num,
// 			secondShape: selectedComponentVariationData["FaceTwo"].num,
// 			thirdShape: selectedComponentVariationData["FaceThree"].num,
// 			firstSkin: selectedComponentVariationData["SkinOne"].num,
// 			secondSkin: selectedComponentVariationData["SkinTwo"].num,
// 			thirdSkin: selectedComponentVariationData["SkinThree"].num,
// 			shapeMix: document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-FaceMix").value,
// 			skinMix: document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-SkinMix").value,
// 			thirdMix: document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-ThirdMix").value,
// 		});
// 	});
// 	document.getElementById(`mainDivBottomLeftBottomDivBottomInputSlider-ThirdMix`).addEventListener('input', function() {
// 		post({
// 			action: "changeFace",
// 			firstShape: selectedComponentVariationData["FaceOne"].num,
// 			secondShape: selectedComponentVariationData["FaceTwo"].num,
// 			thirdShape: selectedComponentVariationData["FaceThree"].num,
// 			firstSkin: selectedComponentVariationData["SkinOne"].num,
// 			secondSkin: selectedComponentVariationData["SkinTwo"].num,
// 			thirdSkin: selectedComponentVariationData["SkinThree"].num,
// 			shapeMix: document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-FaceMix").value,
// 			skinMix: document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-SkinMix").value,
// 			thirdMix: document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-ThirdMix").value,
// 		});
// 	});
// 	// Face Features
// 	let faceFeatData = [
// 		{name: "NoseWidth", variationNumber: 0},
// 		{name: "NosePeak", variationNumber: 1},
// 		{name: "NoseLength", variationNumber: 2},
// 		{name: "NoseBoneCurveness", variationNumber: 3},
// 		{name: "NoseTip", variationNumber: 4},
// 		{name: "NoseBoneTwist", variationNumber: 5},
// 		{name: "EyebrowHeight", variationNumber: 6},
// 		{name: "EyebrowDepth", variationNumber: 7},
// 		{name: "CheekBoneHeight", variationNumber: 8},
// 		{name: "CheekBoneWidth", variationNumber: 9},
// 		{name: "CheekBoneWidth2", variationNumber: 10},
// 		{name: "EyesSquint", variationNumber: 11},
// 		{name: "LipsThickness", variationNumber: 12},
// 		{name: "JawBoneLength", variationNumber: 13},
// 		{name: "JawBoneWidth", variationNumber: 14},
// 		{name: "ChinBoneHeight", variationNumber: 15},
// 		{name: "ChinBoneLength", variationNumber: 16},
// 		{name: "ChinBoneWidth", variationNumber: 17},
// 		{name: "ChinCleft", variationNumber: 18},
// 		{name: "NeckThickness", variationNumber: 19}
// 	];
// 	faceFeatData.forEach(function(data, index) {
// 		document.getElementById(`${data.name}-Slider`).addEventListener('input', function() {
// 			post({action: "changeFaceFeature", name: data.name, num1: data.variationNumber, value: document.getElementById(`${data.name}-Slider`).value / 100});
// 		});
// 	});
// });

function finishCharacterCreation() {
	dialogOpen = true;
	// document.getElementById("MDLCenter").style.filter = "blur(5px)";
	document.getElementById("mainDivDialog").style.display = "flex";
	// document.getElementById("mainDivDialogBG").style.display = "flex";
	document.getElementById("mainDivDialogSpan").innerHTML=translations.confirm_character_creation;
	document.getElementById("mainDivDialogButtons").innerHTML=`
	<div class="mainDivDialogButtonGreen" onclick="finalizeCharacter()">${translations.finalize_character}</div>
	<div class="mainDivDialogButtonRed" onclick="discardCharacterCreation()">${translations.discard}</div>
	<div class="mainDivDialogButtonRed" onclick="closeDialog()">${translations.cancel}</div>
	`;
}

function changeHairTexture(type) {
	if (type === "left") {
		if (variationTexturesData["Hairs"].currentNum > 0) {
			variationTexturesData["Hairs"].currentNum = variationTexturesData["Hairs"].currentNum - 1;
			variationTexturesData["Hairs_2"].currentNum = variationTexturesData["Hairs"].currentNum - 1;
		}
	} else {
		if (variationTexturesData["Hairs"].currentNum < 55) {
			variationTexturesData["Hairs"].currentNum = variationTexturesData["Hairs"].currentNum + 1;
			variationTexturesData["Hairs_2"].currentNum = variationTexturesData["Hairs"].currentNum + 1;
		}
	}
	document.getElementById("hairTextureNumSpan").innerHTML=variationTexturesData["Hairs"].currentNum;
	post({action: "changeHeadOverlay", action2: "Hairs", num1: -1, num2: selectedComponentVariationData["Hairs"].num, num3: variationTexturesData["Hairs"].currentNum, num4: variationTexturesData["Hairs_2"].currentNum, opacity: 1.0});
}

variationTexturesData["HairFade"] = [];
variationTexturesData["HairFade"].currentNum = 0;
function changeHairFade(type) {
	if (type === "left") {
		if (variationTexturesData["HairFade"].currentNum > 0) {
			variationTexturesData["HairFade"].currentNum = variationTexturesData["HairFade"].currentNum - 1;
		}
	} else {
		if (variationTexturesData["HairFade"].currentNum < 1) {
			variationTexturesData["HairFade"].currentNum = variationTexturesData["HairFade"].currentNum + 1;
		}
	}
	document.getElementById("hairFadeNumSpan").innerHTML=variationTexturesData["HairFade"].currentNum;
	post({action: "setHairFade", num1: variationTexturesData["HairFade"].currentNum, num2: selectedComponentVariationData["Hairs"].num});
}

clothRemovedData = [];
function removeCloth(type, num) {
	if (type === "All") {
		removeCloth('Hat', '0');
		removeCloth('Masks', '1');
		removeCloth('Glasses', '1');
		removeCloth('Jacket', '11');
		removeCloth('Bag', '5');
		removeCloth('Hairs', '2');
		removeCloth('Shoes', '6');
		removeCloth('Pants', '4');
		return;
	}
	if (!clothRemovedData[type]) {
		clothRemovedData[type] = true;
		const elements = document.getElementsByClassName(`MDRB-${type}`);
		Array.prototype.filter.call(
			elements,
			(testElement) => testElement.classList.add("mainDivRightButtonSelected"),
		);
		post({action: "removeCloth", type: type, component: Number(num)});
	} else {
		clothRemovedData[type] = null;
		const elements = document.getElementsByClassName(`MDRB-${type}`);
		Array.prototype.filter.call(
			elements,
			(testElement) => testElement.classList.remove("mainDivRightButtonSelected"),
		);
		texture = variationTexturesData[type].currentNum || 0;
		if (type === "Jacket") {
			post({action: "wearCloth", type: type, component: Number(num), num: selectedComponentVariationData[type].num, num1: selectedComponentVariationData["Undershirt"].num, num2: selectedComponentVariationData["Arms/Gloves"].num});
		}
		if (type === "Hat" || type === "Glasses") {
			post({action: "wearCloth", type: type, num1: Number(num), num2: selectedComponentVariationData[type].num, num3: texture});
			return
		}
		post({action: "wearCloth", type: type, component: Number(num), num: selectedComponentVariationData[type].num, num3: texture});
	}
}

function justRemoveCloth(type, num) {
	clothRemovedData[type] = true;
	const elements = document.getElementsByClassName(`MDRB-${type}`);
	Array.prototype.filter.call(
		elements,
		(testElement) => testElement.classList.add("mainDivRightButtonSelected"),
	);
	post({action: "removeCloth", type: type, component: Number(num)});
}

let lastPedChooseTime = 0;
function choosePed(model) {
	closeDialog();
	const now = Date.now();
	if (now - lastPedChooseTime < 5000) return;
	lastPedChooseTime = now;
	if (selectedPed) {
		const prevElem = document.getElementById(`MDLCDivBDiv-Peds-${selectedPed}`);
		if (prevElem) prevElem.classList.remove("MDLCDivBDivSelected");
	}
	selectedPed = model;
	const newElem = document.getElementById(`MDLCDivBDiv-Peds-${selectedPed}`);
	if (newElem) newElem.classList.add("MDLCDivBDivSelected");
	document.getElementById("mainDivBottomLeftBottomDivBottomInput-PedModelInput").value = selectedPed;
	post({action: "loadPed", model: model});
}

function post(data, callback) {
	var xhr = new XMLHttpRequest();
	xhr.open("POST", `https://${GetParentResourceName()}/callback`, true);
	xhr.setRequestHeader('Content-Type', 'application/json');
	xhr.onload = function () {
		if (xhr.status >= 200 && xhr.status < 300) {
			try {
				const response = JSON.parse(xhr.responseText);
				if (callback) callback(response);
			} catch (error) {
				// console.error("JSON Parse Hatası:", error, xhr.responseText);
			}
		} else {
			console.error("Hata: HTTP Status " + xhr.status);
		}
	};
	xhr.send(JSON.stringify(data));
}

function changeComponentVariation(action, minVariationNumber, variationNumber, type) {
	if (type === "left") {
		if (variationsData[action] > Number(minVariationNumber)) {
			variationsData[action] = variationsData[action] - 1;
		}
	} else {
		if (variationsData[action] < Number(minVariationNumber)) {
			variationsData[action] = variationsData[action] + 1;
		}
	}
	changeVariation(Number(variationNumber), variationsData[action], action);
}

function changeTextureVariation2(action, variationNumber, type) {
	if (type === "left") {
		if (variationTexturesData[action].currentNum > 0) {
			variationTexturesData[action].currentNum = variationTexturesData[action].currentNum - 1;
		}
	} else {
		if (variationTexturesData[action].currentNum < variationTexturesData[action].maxNum) {
			variationTexturesData[action].currentNum = variationTexturesData[action].currentNum + 1;
		}
	}
	changeTextureVariation(variationNumber, variationTexturesData[action].currentNum, action);
}

selectedTattooPage = null;
function showTattooPage(page) {
	selectedTattooPage = page;
	let namesData = {
		"ZONE_HEAD": "Head",
		"ZONE_RIGHT_LEG": "RightLeg",
		"ZONE_LEFT_LEG": "LeftLeg",
		"ZONE_LEFT_ARM": "LeftArm",
		"ZONE_RIGHT_ARM": "RightArm",
		"ZONE_TORSO": "Torso"
	};
	let zoneTranslations = {
		"Head": translations.head,
		"RightLeg": translations.rightleg,
		"LeftLeg": translations.leftleg,
		"RightArm": translations.rightarm,
		"LeftArm": translations.leftarm,
		"Torso": translations.torso
	}
	let label = zoneTranslations[page];
	document.getElementById("MDLCDivTopSpan-Tattoo").innerHTML=`${translations.tattoos} | ${label}`;
	document.getElementById('mainDivBottomLeftBottomDivBottom-Tattoo').innerHTML="";
	tattoosData.forEach(function(data, index) {
		if (selectedTattooPage === namesData[data.Zone]) {
			if (currentPedGender === "female") {
				if (data.HashNameFemale !== "") {
					var html = `
					<div class="MDLCDivBDiv MDLCDivBDivBigIMG" id="MDLCDivBDiv-Tattoo-${data.Name}" onclick="changeTattoo('${data.Collection}', '${data.HashNameMale}', '${data.HashNameFemale}', '${data.Zone}', '${data.Price}', '${data.Name}')">
						<img style="${data.style}" src="files/menu/tattoo.svg" style='width: 4vw;'>
						<div id="mainDivBottomLeftBottomDivSpanDiv2" style="top: 5%; text-align: left;">${label} ${index}</div>
						<div id="mainDivBottomLeftBottomDivSpanDiv2" style="bottom: 5%;">${data.Price}${currency}</div>
					</div>`;
					appendHtml(document.getElementById('mainDivBottomLeftBottomDivBottom-Tattoo'), html);
					currentPlayerTattoos.forEach(function(cdata, index) {
						if (cdata) {
							if (cdata.mname === data.Name) {
								document.getElementById(`MDLCDivBDiv-Tattoo-${cdata.mname}`).classList.remove("MDLCDivBDivBigIMG");
								document.getElementById(`MDLCDivBDiv-Tattoo-${cdata.mname}`).classList.add("MDLCDivBDivBigIMGSelected");
								document.getElementById(`MDLCDivBDiv-Tattoo-${cdata.mname}`).classList.add("MDLCDivBDivSelected");
							}
						}
					});
				}
			} else {
				if (data.HashNameMale !== "") {
					var html = `
					<div class="MDLCDivBDiv MDLCDivBDivBigIMG" id="MDLCDivBDiv-Tattoo-${data.Name}" onclick="changeTattoo('${data.Collection}', '${data.HashNameMale}', '${data.HashNameFemale}', '${data.Zone}', '${data.Price}', '${data.Name}')">
						<img style="${data.style}" src="files/menu/tattoo.svg" style='width: 4vw;'>
						<div id="mainDivBottomLeftBottomDivSpanDiv2" style="top: 5%; text-align: left;">${label} ${index}</div>
						<div id="mainDivBottomLeftBottomDivSpanDiv2" style="bottom: 5%;">${data.Price}${currency}</div>
					</div>`;
					appendHtml(document.getElementById('mainDivBottomLeftBottomDivBottom-Tattoo'), html);
					currentPlayerTattoos.forEach(function(cdata, index) {
						if (cdata) {
							if (cdata.mname === data.Name) {
								document.getElementById(`MDLCDivBDiv-Tattoo-${cdata.mname}`).classList.remove("MDLCDivBDivBigIMG");
								document.getElementById(`MDLCDivBDiv-Tattoo-${cdata.mname}`).classList.add("MDLCDivBDivBigIMGSelected");
								document.getElementById(`MDLCDivBDiv-Tattoo-${cdata.mname}`).classList.add("MDLCDivBDivSelected");
							}
						}
					});
				}
			}
		}
	});
}

function changeTattoo(collection, name, name2, zone, price, mname) {
	closeDialog();
	post({action: "changeTattoo", collection: collection, name: name, name2: name2, mname: mname});
	if (clothMenuOpen && currentPlayerTattoos) {
		let existingTattoo = currentPlayerTattoos.find(item => item && item.mname === mname);
		let existingTattoo2 = currentPlayerTattoos2.find(item => item && item.mname === mname);
		if (existingTattoo) {
			currentPlayerTattoos = currentPlayerTattoos.filter(item => item && item.mname !== mname);
			if (!existingTattoo2) {
				clothPayment = clothPayment - Number(price);
				document.getElementById("paymentSpan").innerHTML=clothPayment + currency;
				// document.getElementById("paymentSpan2").innerHTML=clothPayment + currency;
			}
			document.getElementById(`MDLCDivBDiv-Tattoo-${mname}`).classList.add("MDLCDivBDivBigIMG");
			document.getElementById(`MDLCDivBDiv-Tattoo-${mname}`).classList.remove("MDLCDivBDivBigIMGSelected");
			document.getElementById(`MDLCDivBDiv-Tattoo-${mname}`).classList.remove("MDLCDivBDivSelected");
		} else {
			currentPlayerTattoos.push({collection: collection, nameHash: name, nameHash2: name2, Count: 10, mname: mname});
			if (!existingTattoo2) {
				clothPayment = clothPayment + Number(price);
				document.getElementById("paymentSpan").innerHTML=clothPayment + currency;
				// document.getElementById("paymentSpan2").innerHTML=clothPayment + currency;
			}
			document.getElementById(`MDLCDivBDiv-Tattoo-${mname}`).classList.remove("MDLCDivBDivBigIMG");
			document.getElementById(`MDLCDivBDiv-Tattoo-${mname}`).classList.add("MDLCDivBDivBigIMGSelected");
			document.getElementById(`MDLCDivBDiv-Tattoo-${mname}`).classList.add("MDLCDivBDivSelected");
		}
	}
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

function openClothStore() {
	document.getElementById("MDLCenter").innerHTML="";
	document.getElementById("mainDivOutsideButtonDiv-ClothCompare").style.display = "flex";
	generalData.forEach(function(data, index) {
		let display = "flex";
		if (!clothStoreCategories[data.action + "_" + selectedPage2]) display = "none";
		let action = formatString(data.action);
		if (action.includes("highlight_color")) action = "highlight_color";
		if (action.includes("first_")) action = "first_color";
		if (action.includes("second_")) action = "second_color";
		if (data.action.includes("Color")) {
			var html = `
			<div class="MDLCDiv" id="MDLCDiv-${data.action}" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan ${action}"></span>
					<div id="MDLCDivTExpandDiv"><span class="click"></span><div class="MDLCDivTExpandDivBtn" id="mainDivBottomLeftBottomDivTopExpandDivButton-${data.action}"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom" id="MDLCDivBottom-${data.action}">
					<div class="MDLCDivBottomInside" id="mainDivBottomLeftBottomDivBottom-${data.action}"></div>
				</div>
			</div>
			`;
		} else if (data.currentDrawableVariationOpacity || data.action === "Blush" || data.action === "Lipstick" || data.action === "Makeup") {
			var html = `
			<div class="MDLCDiv" id="MDLCDiv-${data.action}" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan ${action}"></span>
					<div id="MDLCDivTExpandDiv"><span class="click"></span><div class="MDLCDivTExpandDivBtn" id="mainDivBottomLeftBottomDivTopExpandDivButton-${data.action}"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom">
					<div class="MDLCDivBottomInside" id="mainDivBottomLeftBottomDivBottom-${data.action}"></div>
					<div class="MDLCDBVariations">
						<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="${data.action}-OpacitySlider" type="range" min="1" max="100" value="80"></input>
					</div>
				</div>
			</div>
			`;
		} else if (data.action === "HairFade") {
			var html = `
			<div class="MDLCDiv" id="MDLCDiv-${data.action}" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan">${translations.hair_fade}</span>
					<div id="MDLCDivTExpandDiv" style="opacity: 0;"><span class="click"></span><div class="MDLCDivTExpandDivBtn"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom">
					<div class="MDLCDBVariations">
						<div class="MDLCDBVariationDiv2">
							<div class="MDLCDBVDBtn2" onclick="changeHairFade('left')"><i class="fa-regular fa-chevron-left"></i></div>
							<span id="hairFadeNumSpan">0</span>
							<div class="MDLCDBVDBtn2" onclick="changeHairFade('right')"><i class="fa-regular fa-chevron-right"></i></div>
						</div>
					</div>
				</div>
			</div>
			`;
		} else if (data.action === "HairTexture") {
			var html = `
			<div class="MDLCDiv" id="MDLCDiv-${data.action}" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan">${translations.hair_texture}</span>
					<div id="MDLCDivTExpandDiv" style="opacity: 0;"><span class="click"></span><div class="MDLCDivTExpandDivBtn"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom">
					<div class="MDLCDBVariations">
						<div class="MDLCDBVariationDiv2">
							<div class="MDLCDBVDBtn2" onclick="changeHairTexture('left')"><i class="fa-regular fa-chevron-left"></i></div>
							<span id="hairTextureNumSpan">0</span>
							<div class="MDLCDBVDBtn2" onclick="changeHairTexture('right')"><i class="fa-regular fa-chevron-right"></i></div>
						</div>
					</div>
				</div>
			</div>
			`;
		} else {
			var html = `
			<div class="MDLCDiv" id="MDLCDiv-${data.action}" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan ${action}"></span>
					<div id="MDLCDivTExpandDiv"><span class="click"></span><div class="MDLCDivTExpandDivBtn" id="mainDivBottomLeftBottomDivTopExpandDivButton-${data.action}"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom">
					<div class="MDLCDivBottomInside" id="mainDivBottomLeftBottomDivBottom-${data.action}"></div>
					<div class="MDLCDBVariations">
						<div class="MDLCDBVariationDiv">
							<div class="MDLCDBVDBtn" id="mainDivBottomLeftBottomDivBottom-${data.action}BtnLeft-ComponentVariation"><i class="fa-regular fa-chevron-left"></i></div>
							<span id="mainDivBottomLeftBottomDivBottom-${data.action}Span-ComponentVariation"></span>
							<div class="MDLCDBVDBtn" id="mainDivBottomLeftBottomDivBottom-${data.action}BtnRight-ComponentVariation"><i class="fa-regular fa-chevron-right"></i></div>
						</div>
						<div class="MDLCDBVariationDiv">
							<div class="MDLCDBVDBtn" id="mainDivBottomLeftBottomDivBottom-${data.action}BtnLeft-TextureVariation"><i class="fa-regular fa-chevron-left"></i></div>
							<span id="mainDivBottomLeftBottomDivBottom-${data.action}Span-TextureVariation"></span>
							<div class="MDLCDBVDBtn" id="mainDivBottomLeftBottomDivBottom-${data.action}BtnRight-TextureVariation"><i class="fa-regular fa-chevron-right"></i></div>
						</div>
					</div>
				</div>
			</div>
			`;
		}
		appendHtml(document.getElementById(`MDLCenter`), html);
	});
	if (shopType === "clothing") {
		generalData.forEach(function(data, index) {
			variationsData[data.action] = -1;
			variationTexturesData[data.action] = {};
			variationTexturesData[data.action].currentNum = 0;
			variationTexturesData[data.action + "_2"] = {};
			variationTexturesData[data.action + "_2"].currentNum = 0;
			if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}Span-ComponentVariation`)) {
				document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}Span-ComponentVariation`).innerHTML="0";
			}
			if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}Span-TextureVariation`)) {
				document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}Span-TextureVariation`).innerHTML="0";
			}
			if (data.btnClick) {
				const button = document.getElementById(`mainDivBottomLeftBottomDivTopExpandDivButton-${data.action}`);
				button.onclick = null;
				button.onclick = (e) => {
					expandDiv(`mainDivBottomLeftBottomDivBottom-${data.action}`);
				};
			}
			if (data.btnClick2) {
				const button = document.getElementById(`mainDivBottomLeftBottomDivTopExpandDivButton-${data.action}`);
				button.onclick = null;
				button.onclick = (e) => {
					expandDiv2(data.action);
				};
			}
			if (!data.minVariationNumber) data.minVariationNumber = 0;
			// Component Variation
			if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}BtnLeft-ComponentVariation`)) {
				document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}BtnLeft-ComponentVariation`).setAttribute("onclick", `changeComponentVariation('${data.action}', '${data.minVariationNumber}', '${data.variationNumber}', 'left')`);
			}
			if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}BtnRight-ComponentVariation`)) {
				document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}BtnRight-ComponentVariation`).setAttribute("onclick", `changeComponentVariation('${data.action}', '${data.maxVariationNumber}', '${data.variationNumber}', 'right')`);
			}
			// Texture Variation
			if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}BtnLeft-TextureVariation`)) {
				document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}BtnLeft-TextureVariation`).setAttribute("onclick", `changeTextureVariation2('${data.action}', '${data.variationNumber}', 'left')`);
			}
			if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}BtnRight-TextureVariation`)) {
				document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}BtnRight-TextureVariation`).setAttribute("onclick", `changeTextureVariation2('${data.action}', '${data.variationNumber}', 'right')`);
			}
			if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}`)) {
				document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}`).innerHTML="";
			}
			data.data.forEach(function(cData, index) {
				let id = cData.num;
				if (data.search === true && id === -1 || data.action === "Masks" && index === 0 || data.action === "Vest" && index === 0 || data.action === "Bag" && index === 0 || data.action === "Scarfs/Necklaces" && index === 0 || data.action === "Decals" && index === 0 || data.action === "Glasses" && index === 0) {
					var html = `
					<div class="MDLCDivBDiv MDLCDivBDivBigIMG" id="MDLCDivBDiv-${data.action}-${id}" onclick="changeVariation('${data.variationNumber}', '${cData.num}', '${data.action}')">
						<img crossOrigin="anonymous" src="files/menu/default.svg">
					</div>
					`;
					appendHtml(document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}`), html);
					return
				}
				if (data.action.includes("Color") && data.action != "EyeColor") {
					var html = `<div class="MDLCDivBDivColor" id="MDLCDivBDiv-${data.action}-${index}" style="background: rgba(${cData.r}, ${cData.g}, ${cData.b}, 255)" onclick="changeVariationColor('${data.action}', '${index}')"></div>`;
					appendHtml(document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}`), html);
					return
				}
				let bottomSpan = index;
				if (bottomSpan === 0) {
					bottomSpan = translations.none;
				} 
				if (data.action === "Hat" || data.action === "Glasses" || data.action === "Earrings" || data.action === "Watches" || data.action === "Bracelets") {
					var html = `
					<div class="MDLCDivBDiv ${data.imgType}" id="MDLCDivBDiv-${data.action}-${id}" onclick="changePropVariation('${data.variationNumber}', '${id}', '${data.action}')">
						<img crossOrigin="anonymous" style="${data.style}" src="${cData.image}" onerror="this.onerror=null; this.src='files/menu/unknown.svg'; this.style='width: 4vw;';">
						<div id="mainDivBottomLeftBottomDivSpanDiv">${bottomSpan}</div>
					</div>`;
					appendHtml(document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}`), html);
					if (!selectedComponentVariationData[data.action]) {
						changePropVariation(data.variationNumber, variationsData[data.action], data.action);
					}
					return
				}
				data.style = data.style || "";
				if (currentPlayerSkin[data.action] && currentPlayerSkin[data.action].Blacklist && currentPlayerSkin[data.action].Blacklist[cData.num] === true) {
					var html = `
					<div class="MDLCDivBDiv ${data.imgType}" id="MDLCDivBDiv-${data.action}-${id}" style="opacity: 0.5;">
						<img crossOrigin="anonymous" style="${data.style}" src="${cData.image}" onerror="this.onerror=null; this.src='files/menu/unknown.svg'; this.style='width: 4vw;';">
						<div id="mainDivBottomLeftBottomDivSpanDiv">${bottomSpan}</div>
					</div>`;
				} else {
					var html = `
					<div class="MDLCDivBDiv ${data.imgType}" id="MDLCDivBDiv-${data.action}-${id}" onclick="changeVariation('${data.variationNumber}', '${cData.num}', '${data.action}')">
						<img crossOrigin="anonymous" style="${data.style}" src="${cData.image}" onerror="this.onerror=null; this.src='files/menu/unknown.svg'; this.style='width: 4vw;';">
						<div id="mainDivBottomLeftBottomDivSpanDiv">${bottomSpan}</div>
					</div>`;
				}
				appendHtml(document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}`), html);
			});
			if (data.currentDrawableVariation !== null || data.currentDrawableVariation !== undefined) {
				changeVariation(data.variationNumber, data.currentDrawableVariation, data.action, data.currentTextureDrawableVariation);
			}
			if (data.currentTextureDrawableVariation !== null || data.currentTextureDrawableVariation !== undefined) {
				changeTextureVariation(data.variationNumber, data.currentTextureDrawableVariation, data.action);
			}
			if (data.action === "FacialHairs" || data.action === "Eyebrows" || data.action === "Blemishes" || data.action === "Ageing" || data.action === "Complexion" || data.action === "SunDamage" || data.action === "MolesFreckles" || data.action === "ChestHair" || data.action === "BodyBlemishes" || data.action === "AddBodyBlemishes") {
				if (data.currentDrawableVariationOpacity) {
					let opacity = 100;
					if (document.getElementById(`${data.action}-OpacitySlider`)) {
						opacity = data.currentDrawableVariationOpacity * 100;
						document.getElementById(`${data.action}-OpacitySlider`).value = data.currentDrawableVariationOpacity * 100;
					}
					let skinData = [
						{name: "FacialHairs", mainName: "FacialHairs", variationNumber: 1},
						{name: "Eyebrows", mainName: "Eyebrows", variationNumber: 2},
						{name: "Blemishes", mainName: "Blemishes", variationNumber: 0},
						{name: "Ageing", mainName: "Ageing", variationNumber: 3},
						{name: "Complexion", mainName: "Complexion", variationNumber: 6},
						{name: "SunDamage", mainName: "SunDamage", variationNumber: 7},
						{name: "MolesFreckles", mainName: "MolesFreckles", variationNumber: 9},
						{name: "ChestHair", mainName: "ChestHair", variationNumber: 10},
						{name: "ChestHairHome", mainName: "ChestHair", variationNumber: 10},
						{name: "BodyBlemishes", mainName: "BodyBlemishes", variationNumber: 11},
						{name: "AddBodyBlemishes", mainName: "AddBodyBlemishes", variationNumber: 12}
					];
					skinData.forEach(function(sdata, index) {
						if (!selectedComponentVariationData[sdata.mainName]) {return};
						if (!variationTexturesData[sdata.mainName]) {return};
						post({action: "changeHeadOverlay", action2: sdata.mainName, num1: Number(sdata.variationNumber), num2: selectedComponentVariationData[sdata.mainName].num, num3: variationTexturesData[sdata.mainName].currentNum, opacity: opacity});
					});
				}
			}
		});
	} else if (shopType === "barber") {
		generalData.forEach(function(data, index) {
			variationsData[data.action] = -1;
			variationTexturesData[data.action] = {};
			variationTexturesData[data.action].currentNum = 0;
			variationTexturesData[data.action + "_2"] = {};
			variationTexturesData[data.action + "_2"].currentNum = 0;
			if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}Span-ComponentVariation`)) {
				document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}Span-ComponentVariation`).innerHTML="0";
			}
			if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}Span-TextureVariation`)) {
				document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}Span-TextureVariation`).innerHTML="0";
			}
			if (data.btnClick) {
				const button = document.getElementById(`mainDivBottomLeftBottomDivTopExpandDivButton-${data.action}`);
				button.onclick = null;
				button.onclick = (e) => {
					expandDiv(`mainDivBottomLeftBottomDivBottom-${data.action}`);
				};
			}
			if (data.btnClick2) {
				const button = document.getElementById(`mainDivBottomLeftBottomDivTopExpandDivButton-${data.action}`);
				button.onclick = null;
				button.onclick = (e) => {
					expandDiv2(data.action);
				};
				expandDiv2(data.action);
				expandDiv2(data.action);
			}
			if (!data.minVariationNumber) data.minVariationNumber = 0;
			// Component Variation
			if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}BtnLeft-ComponentVariation`)) {
				document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}BtnLeft-ComponentVariation`).setAttribute("onclick", `changeComponentVariation('${data.action}', '${data.minVariationNumber}', '${data.variationNumber}', 'left')`);
			}
			if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}BtnRight-ComponentVariation`)) {
				document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}BtnRight-ComponentVariation`).setAttribute("onclick", `changeComponentVariation('${data.action}', '${data.maxVariationNumber}', '${data.variationNumber}', 'right')`);
			}
			// Texture Variation
			if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}BtnLeft-TextureVariation`)) {
				document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}BtnLeft-TextureVariation`).setAttribute("onclick", `changeTextureVariation2('${data.action}', '${data.variationNumber}', 'left')`);
			}
			if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}BtnRight-TextureVariation`)) {
				document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}BtnRight-TextureVariation`).setAttribute("onclick", `changeTextureVariation2('${data.action}', '${data.variationNumber}', 'right')`);
			}
			if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}`)) {
				document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}`).innerHTML="";
			}
			data.data.forEach(function(cData, index) {
				let id = cData.num;
				if (data.search === true && id === -1 || data.action === "Masks" && index === 0) {
					var html = `
					<div class="MDLCDivBDiv MDLCDivBDivBigIMG" id="MDLCDivBDiv-${data.action}-${id}" onclick="changeVariation('${data.variationNumber}', '${cData.num}', '${data.action}')">
						<img src="files/menu/default.svg">
					</div>
					`;
					appendHtml(document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}`), html);
					return
				}
				if (data.action.includes("Color") && data.action != "EyeColor") {
					var html = `<div class="MDLCDivBDivColor" id="MDLCDivBDiv-${data.action}-${index}" style="background: rgba(${cData.r}, ${cData.g}, ${cData.b}, 255)" onclick="changeVariationColor('${data.action}', '${index}')"></div>`;
					appendHtml(document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}`), html);
					return
				}
				let bottomSpan = index;
				if (bottomSpan === 0) {
					bottomSpan = translations.none;
				} 
				data.style = data.style || "";
				var html = `
				<div class="MDLCDivBDiv ${data.imgType}" id="MDLCDivBDiv-${data.action}-${id}" onclick="changeVariation('${data.variationNumber}', '${cData.num}', '${data.action}')">
					<img style="${data.style}" src="${cData.image}" onerror="this.onerror=null; this.src='files/menu/unknown.svg'; this.style='width: 4vw;';">
					<div id="mainDivBottomLeftBottomDivSpanDiv">${bottomSpan}</div>
				</div>`;
				appendHtml(document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}`), html);
			});
			setTimeout(() => {
				if (data.currentDrawableVariation !== null || data.currentDrawableVariation !== undefined) {
					changeVariation(data.variationNumber, data.currentDrawableVariation, data.action, data.currentTextureDrawableVariation);
				}
				if (data.currentTextureDrawableVariation !== null || data.currentTextureDrawableVariation !== undefined) {
					changeTextureVariation(data.variationNumber, data.currentTextureDrawableVariation, data.action);
				}
				if (data.action === "FacialHairs" || data.action === "Eyebrows" || data.action === "Blemishes" || data.action === "Ageing" || data.action === "Complexion" || data.action === "SunDamage" || data.action === "MolesFreckles" || data.action === "ChestHair" || data.action === "BodyBlemishes" || data.action === "AddBodyBlemishes") {
					if (data.currentDrawableVariationOpacity && document.getElementById(`${data.action}-OpacitySlider`)) {
						document.getElementById(`${data.action}-OpacitySlider`).value = data.currentDrawableVariationOpacity * 100;
						let skinData = [
							{name: "FacialHairs", mainName: "FacialHairs", variationNumber: 1},
							{name: "Eyebrows", mainName: "Eyebrows", variationNumber: 2},
							{name: "Blemishes", mainName: "Blemishes", variationNumber: 0},
							{name: "Ageing", mainName: "Ageing", variationNumber: 3},
							{name: "Complexion", mainName: "Complexion", variationNumber: 6},
							{name: "SunDamage", mainName: "SunDamage", variationNumber: 7},
							{name: "MolesFreckles", mainName: "MolesFreckles", variationNumber: 9},
							{name: "ChestHair", mainName: "ChestHair", variationNumber: 10},
							{name: "BodyBlemishes", mainName: "BodyBlemishes", variationNumber: 11},
							{name: "AddBodyBlemishes", mainName: "AddBodyBlemishes", variationNumber: 12}
						];
						skinData.forEach(function(sdata, index) {
							if (!selectedComponentVariationData[sdata.mainName]) {return};
							if (!variationTexturesData[sdata.mainName]) {return};
							post({action: "changeHeadOverlay", action2: sdata.mainName, num1: Number(sdata.variationNumber), num2: selectedComponentVariationData[sdata.mainName].num, num3: variationTexturesData[sdata.mainName].currentNum, opacity: document.getElementById(`${data.action}-OpacitySlider`).value});
						});
					}
				}
				if (data.action === "mblOpacity") {
					let makeupData = [
						{name: "Makeup", variationNumber: 4},
						{name: "Blush", variationNumber: 5},
						{name: "Lipstick", variationNumber: 8}
					];
					makeupData.forEach(function(mdata, index) {
						if (!selectedComponentVariationData[mdata.name]) {return};
						if (!variationTexturesData[mdata.name]) {return};
						document.getElementById(`${mdata.name}-OpacitySlider`).value = data[mdata.name + "Opacity"] * 100;
						post({action: "changeHeadOverlay", action2: mdata.name, num1: Number(mdata.variationNumber), num2: selectedComponentVariationData[mdata.name].num, num3: variationTexturesData[mdata.name].currentNum, opacity: document.getElementById(`${mdata.name}-OpacitySlider`).value});
					});
				}
				document.querySelectorAll('.mainDivBottomLeftBottomDivBottomInputSlider').forEach(slider => {
					const updateSliderBackground = (slider) => {
						const value = slider.value;
						const max = slider.max;
						const percentage = (value / max) * 100;
						slider.style.background = `linear-gradient(90deg, #00FFEA ${percentage}%, rgba(255, 255, 255, 0) ${percentage}%), radial-gradient(124.16% 111.18% at 50% 50%, rgba(255, 255, 255, 0.15) 0%, rgba(255, 255, 255, 0.00) 100%)`;
					};
					updateSliderBackground(slider);
					slider.addEventListener('input', function() {
						updateSliderBackground(this);
					});
				});
				document.querySelectorAll('.mainDivBottomLeftBottomDivBottomInputSlider2').forEach(slider => {
					const updateSliderBackground = (slider) => {
						const value = slider.value;
						const max = slider.max;
						const percentage = (value / max) * 100;
						slider.style.background = `linear-gradient(90deg, #00FFEA ${percentage}%, rgba(255, 255, 255, 0) ${percentage}%), radial-gradient(124.16% 111.18% at 50% 50%, rgba(255, 255, 255, 0.15) 0%, rgba(255, 255, 255, 0.00) 100%)`;
					};
					updateSliderBackground(slider);
					slider.addEventListener('input', function() {
						updateSliderBackground(this);
					});
				});
				let makeupData = [
					{name: "Makeup", variationNumber: 4},
					{name: "Blush", variationNumber: 5},
					{name: "Lipstick", variationNumber: 8},
				];
				makeupData.forEach(function(data, index) {
					let name = data.name;
					document.getElementById(`${data.name}-OpacitySlider`).addEventListener('input', function() {
						if (!selectedComponentVariationData[data.name]) {return};
						if (!variationTexturesData[data.name]) {return};
						post({action: "changeHeadOverlay", action2: data.name, num1: Number(data.variationNumber), num2: selectedComponentVariationData[data.name].num, num3: variationTexturesData[data.name].currentNum, opacity: document.getElementById(`${name}-OpacitySlider`).value});
					});
				});
				let skinData = [
					{name: "FacialHairs", mainName: "FacialHairs", variationNumber: 1},
					{name: "Eyebrows", mainName: "Eyebrows", variationNumber: 2},
					{name: "Blemishes", mainName: "Blemishes", variationNumber: 0},
					{name: "Ageing", mainName: "Ageing", variationNumber: 3},
					{name: "Complexion", mainName: "Complexion", variationNumber: 6},
					{name: "SunDamage", mainName: "SunDamage", variationNumber: 7},
					{name: "MolesFreckles", mainName: "MolesFreckles", variationNumber: 9},
					{name: "ChestHair", mainName: "ChestHair", variationNumber: 10},
					{name: "BodyBlemishes", mainName: "BodyBlemishes", variationNumber: 11},
					{name: "AddBodyBlemishes", mainName: "AddBodyBlemishes", variationNumber: 12}
				];
				skinData.forEach(function(data, index) {
					if (!document.getElementById(`${data.name}-OpacitySlider`)) return;
					document.getElementById(`${data.name}-OpacitySlider`).addEventListener('input', function() {
						if (!selectedComponentVariationData[data.mainName]) {return};
						if (!variationTexturesData[data.mainName]) {return};
						post({action: "changeHeadOverlay", action2: data.mainName, num1: Number(data.variationNumber), num2: selectedComponentVariationData[data.mainName].num, num3: variationTexturesData[data.mainName].currentNum, opacity: document.getElementById(`${data.name}-OpacitySlider`).value});
					});
				});
			}, 0);
		});
	} else if (shopType === "tattoo") {
		var html = `
		<div class="MDLCDiv" id="MDLCDiv-Tattoo">
			<div class="MDLCDivTop">
				<span class="MDLCDivTopSpan" id="MDLCDivTopSpan-Tattoo"></span>
				<div id="MDLCDivTExpandDiv"><span class="click"></span><div class="MDLCDivTExpandDivBtn" id="mainDivBottomLeftBottomDivTopExpandDivButton-Tattoo"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
			</div>
			<div class="MDLCDivBottom">
				<div class="MDLCDivBottomInside" id="mainDivBottomLeftBottomDivBottom-Tattoo"></div>
			</div>
		</div>
		`;
		appendHtml(document.getElementById(`MDLCenter`), html);
		const button = document.getElementById(`mainDivBottomLeftBottomDivTopExpandDivButton-Tattoo`);
		button.onclick = null;
		button.onclick = (e) => {
			expandDiv(`mainDivBottomLeftBottomDivBottom-Tattoo`);
		};
		expandData['Tattoo'] = null;
		expandDiv(`mainDivBottomLeftBottomDivBottom-Tattoo`);
		generalData.forEach(function(data, index) {
			variationsData[data.action] = -1;
			variationTexturesData[data.action] = {};
			variationTexturesData[data.action].currentNum = 0;
			variationTexturesData[data.action + "_2"] = {};
			variationTexturesData[data.action + "_2"].currentNum = 0;
			if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}Span-ComponentVariation`)) {
				document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}Span-ComponentVariation`).innerHTML="0";
			}
			if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}Span-TextureVariation`)) {
				document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}Span-TextureVariation`).innerHTML="0";
			}
			if (data.btnClick) {
				const button = document.getElementById(`mainDivBottomLeftBottomDivTopExpandDivButton-${data.action}`);
				button.onclick = null;
				button.onclick = (e) => {
					expandDiv(`mainDivBottomLeftBottomDivBottom-${data.action}`);
				};
			}
			if (data.btnClick2) {
				const button = document.getElementById(`mainDivBottomLeftBottomDivTopExpandDivButton-${data.action}`);
				button.onclick = null;
				button.onclick = (e) => {
					expandDiv2(data.action);
				};
			}
			if (!data.minVariationNumber) data.minVariationNumber = 0;
			// Component Variation
			if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}BtnLeft-ComponentVariation`)) {
				document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}BtnLeft-ComponentVariation`).setAttribute("onclick", `changeComponentVariation('${data.action}', '${data.minVariationNumber}', '${data.variationNumber}', 'left')`);
			}
			if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}BtnRight-ComponentVariation`)) {
				document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}BtnRight-ComponentVariation`).setAttribute("onclick", `changeComponentVariation('${data.action}', '${data.maxVariationNumber}', '${data.variationNumber}', 'right')`);
			}
			// Texture Variation
			if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}BtnLeft-TextureVariation`)) {
				document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}BtnLeft-TextureVariation`).setAttribute("onclick", `changeTextureVariation2('${data.action}', '${data.variationNumber}', 'left')`);
			}
			if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}BtnRight-TextureVariation`)) {
				document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}BtnRight-TextureVariation`).setAttribute("onclick", `changeTextureVariation2('${data.action}', '${data.variationNumber}', 'right')`);
			}
			if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}`)) {
				document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}`).innerHTML="";
			}
			data.data.forEach(function(cData, index) {
				let id = cData.num;
				if (data.search === true && id === -1 || data.action === "Masks" && index === 0) {
					var html = `
					<div class="MDLCDivBDiv MDLCDivBDivBigIMG" id="MDLCDivBDiv-${data.action}-${id}" onclick="changeVariation('${data.variationNumber}', '${cData.num}', '${data.action}')">
						<img src="files/menu/default.svg">
					</div>
					`;
					appendHtml(document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}`), html);
					return
				}
				if (data.action.includes("Color") && data.action != "EyeColor") {
					var html = `<div class="MDLCDivBDivColor" id="MDLCDivBDiv-${data.action}-${index}" style="background: rgba(${cData.r}, ${cData.g}, ${cData.b}, 255)" onclick="changeVariationColor('${data.action}', '${index}')"></div>`;
					appendHtml(document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}`), html);
					return
				}
				let bottomSpan = index;
				if (bottomSpan === 0) {
					bottomSpan = translations.none;
				} 
				if (data.action === "Hat" || data.action === "Glasses" || data.action === "Earrings" || data.action === "Watches" || data.action === "Bracelets") {
					var html = `
					<div class="MDLCDivBDiv ${data.imgType}" id="MDLCDivBDiv-${data.action}-${id}" onclick="changePropVariation('${data.variationNumber}', '${id}', '${data.action}')">
						<img style="${data.style}" src="${cData.image}" onerror="this.onerror=null; this.src='files/menu/unknown.svg'; this.style='width: 4vw;';">
						<div id="mainDivBottomLeftBottomDivSpanDiv">${bottomSpan}</div>
					</div>`;
					appendHtml(document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}`), html);
					if (!selectedComponentVariationData[data.action]) {
						changePropVariation(data.variationNumber, variationsData[data.action], data.action);
					}
					return
				}
				data.style = data.style || "";
				var html = `
				<div class="MDLCDivBDiv ${data.imgType}" id="MDLCDivBDiv-${data.action}-${id}" onclick="changeVariation('${data.variationNumber}', '${cData.num}', '${data.action}')">
					<img style="${data.style}" src="${cData.image}" onerror="this.onerror=null; this.src='files/menu/unknown.svg'; this.style='width: 4vw;';">
					<div id="mainDivBottomLeftBottomDivSpanDiv">${bottomSpan}</div>
				</div>`;
				appendHtml(document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}`), html);
			});
			if (data.currentDrawableVariation !== null || data.currentDrawableVariation !== undefined) {
				changeVariation(data.variationNumber, data.currentDrawableVariation, data.action, data.currentTextureDrawableVariation);
			}
			if (data.currentTextureDrawableVariation !== null || data.currentTextureDrawableVariation !== undefined) {
				changeTextureVariation(data.variationNumber, data.currentTextureDrawableVariation, data.action);
			}
		});
		selectedPage2 = 1;
		justRemoveCloth('Hat', '0');
		justRemoveCloth('Masks', '1');
		justRemoveCloth('Glasses', '1');
		justRemoveCloth('Jacket', '11');
		justRemoveCloth('Bag', '5');
		justRemoveCloth('Hairs', '2');
		justRemoveCloth('Shoes', '6');
		justRemoveCloth('Pants', '4');
		showTattooPage('Head');
		document.getElementById("mainDivOutsideButtonDiv-ClothCompare").style.display = "none";
	}
	for (var key in translations) {
		if (translations.hasOwnProperty(key)) {
			var elements = document.getElementsByClassName(key);
			for (var i = 0; i < elements.length; i++) {
				elements[i].innerHTML = translations[key];
			}
		}
	}
}

showClothRemoverState = false;
function showClothRemover() {
	showClothRemoverState = !showClothRemoverState;
	if (showClothRemoverState) {
		document.getElementById("mainDivOutsideButton-showClothRemover").classList.add("mainDivOutsideButtonActive");
		document.querySelector(".mainDivRight").style.display = "flex";
		document.getElementById("mainDivOutsideButtons").style.left = "32%";
	} else {
		document.querySelector(".mainDivRight").style.display = "none";
		document.getElementById("mainDivOutsideButton-showClothRemover").classList.remove("mainDivOutsideButtonActive");
		document.getElementById("mainDivOutsideButtons").style.left = "26.8%";
	}
}

let sa = false;
function openCreateCharMenuWithoutReset(gender) {
	document.getElementById("MDLCenter").innerHTML="";
	generalData.forEach(function(data, index) {
		let display = "flex";
		if (!clothStoreCategories[data.action + "_" + selectedPage2]) display = "none";
		let action = formatString(data.action);
		if (action.includes("highlight_color")) action = "highlight_color";
		if (action.includes("first_")) action = "first_color";
		if (action.includes("second_")) action = "second_color";
		if (data.data && JSON.stringify(data.data) === "[]" && !data.passDataControl) return;
		if (gender === "female") {
			if (data.action === "FacialHairs" || data.action === "FacialHairsColors" || data.action === "FacialHairsHighlightColors") {
				display = "none";
			}
		}
		if (data.action.includes("Color")) {
			var html = `
			<div class="MDLCDiv" id="MDLCDiv-${data.action}" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan ${action}"></span>
					<div id="MDLCDivTExpandDiv"><span class="click"></span><div class="MDLCDivTExpandDivBtn" id="mainDivBottomLeftBottomDivTopExpandDivButton-${data.action}"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom" id="MDLCDivBottom-${data.action}">
					<div class="MDLCDivBottomInside" id="mainDivBottomLeftBottomDivBottom-${data.action}"></div>
				</div>
			</div>
			`;
		} else if (data.currentDrawableVariationOpacity || data.action === "Blush" || data.action === "Lipstick" || data.action === "Makeup" || data.action === "FacialHairs" || data.action === "Eyebrows" || data.action === "Blemishes" || data.action === "Ageing" || data.action === "Complexion" || data.action === "SunDamage" || data.action === "MolesFreckles" || data.action === "ChestHair" || data.action === "BodyBlemishes" || data.action === "AddBodyBlemishes") {
			var html = `
			<div class="MDLCDiv" id="MDLCDiv-${data.action}" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan ${action}"></span>
					<div id="MDLCDivTExpandDiv"><span class="click"></span><div class="MDLCDivTExpandDivBtn" id="mainDivBottomLeftBottomDivTopExpandDivButton-${data.action}"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom">
					<div class="MDLCDivBottomInside" id="mainDivBottomLeftBottomDivBottom-${data.action}"></div>
					<div class="MDLCDBVariations">
						<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="${data.action}-OpacitySlider" type="range" min="1" max="100" value="80"></input>
					</div>
				</div>
			</div>
			`;
		} else if (data.action === "Hairs") {
			var html = `
			<div class="MDLCDiv" id="MDLCDiv-${data.action}" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan ${action}"></span>
					<div id="MDLCDivTExpandDiv"><span class="click"></span><div class="MDLCDivTExpandDivBtn" id="mainDivBottomLeftBottomDivTopExpandDivButton-${data.action}"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom">
					<div class="MDLCDivBottomInside" id="mainDivBottomLeftBottomDivBottom-${data.action}"></div>
				</div>
			</div>
			`;
		} else if (data.action === "HairFade") {
			var html = `
			<div class="MDLCDiv" id="MDLCDiv-${data.action}" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan">${translations.hair_fade}</span>
					<div id="MDLCDivTExpandDiv" style="opacity: 0;"><span class="click"></span><div class="MDLCDivTExpandDivBtn"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom">
					<div class="MDLCDBVariations">
						<div class="MDLCDBVariationDiv2">
							<div class="MDLCDBVDBtn2" onclick="changeHairFade('left')"><i class="fa-regular fa-chevron-left"></i></div>
							<span id="hairFadeNumSpan">0</span>
							<div class="MDLCDBVDBtn2" onclick="changeHairFade('right')"><i class="fa-regular fa-chevron-right"></i></div>
						</div>
					</div>
				</div>
			</div>
			`;
		} else if (data.action === "HairTexture") {
			var html = `
			<div class="MDLCDiv" id="MDLCDiv-${data.action}" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan">${translations.hair_texture}</span>
					<div id="MDLCDivTExpandDiv" style="opacity: 0;"><span class="click"></span><div class="MDLCDivTExpandDivBtn"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom">
					<div class="MDLCDBVariations">
						<div class="MDLCDBVariationDiv2">
							<div class="MDLCDBVDBtn2" onclick="changeHairTexture('left')"><i class="fa-regular fa-chevron-left"></i></div>
							<span id="hairTextureNumSpan">0</span>
							<div class="MDLCDBVDBtn2" onclick="changeHairTexture('right')"><i class="fa-regular fa-chevron-right"></i></div>
						</div>
					</div>
				</div>
			</div>
			`;
		} else if (data.action === "FemalePeds" || data.action === "MalePeds") {
			var html = `
			<div class="MDLCDiv" id="MDLCDiv-${data.action}" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan ${action}"></span>
					<div id="MDLCDivTExpandDiv"><span class="click"></span><div class="MDLCDivTExpandDivBtn" id="mainDivBottomLeftBottomDivTopExpandDivButton-${data.action}"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom">
					<div class="MDLCDivBottomInside" id="mainDivBottomLeftBottomDivBottom-${data.action}"></div>
				</div>
			</div>
			`;
		} else if (data.currentTextureDrawableVariation !== undefined) {
			var html = `
			<div class="MDLCDiv" id="MDLCDiv-${data.action}" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan ${action}"></span>
					<div id="MDLCDivTExpandDiv"><span class="click"></span><div class="MDLCDivTExpandDivBtn" id="mainDivBottomLeftBottomDivTopExpandDivButton-${data.action}"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom">
					<div class="MDLCDivBottomInside" id="mainDivBottomLeftBottomDivBottom-${data.action}"></div>
					<div class="MDLCDBVariations">
						<div class="MDLCDBVariationDiv">
							<div class="MDLCDBVDBtn" id="mainDivBottomLeftBottomDivBottom-${data.action}BtnLeft-ComponentVariation"><i class="fa-regular fa-chevron-left"></i></div>
							<span id="mainDivBottomLeftBottomDivBottom-${data.action}Span-ComponentVariation"></span>
							<div class="MDLCDBVDBtn" id="mainDivBottomLeftBottomDivBottom-${data.action}BtnRight-ComponentVariation"><i class="fa-regular fa-chevron-right"></i></div>
						</div>
						<div class="MDLCDBVariationDiv">
							<div class="MDLCDBVDBtn" id="mainDivBottomLeftBottomDivBottom-${data.action}BtnLeft-TextureVariation"><i class="fa-regular fa-chevron-left"></i></div>
							<span id="mainDivBottomLeftBottomDivBottom-${data.action}Span-TextureVariation"></span>
							<div class="MDLCDBVDBtn" id="mainDivBottomLeftBottomDivBottom-${data.action}BtnRight-TextureVariation"><i class="fa-regular fa-chevron-right"></i></div>
						</div>
					</div>
				</div>
			</div>
			`;
		} else if (data.action === "SkinThree") {
			var html = `
			<div class="MDLCDiv" id="MDLCDiv-${data.action}" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan ${action}"></span>
					<div id="MDLCDivTExpandDiv"><span class="click"></span><div class="MDLCDivTExpandDivBtn" id="mainDivBottomLeftBottomDivTopExpandDivButton-${data.action}"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom">
					<div class="MDLCDivBottomInside" id="mainDivBottomLeftBottomDivBottom-${data.action}"></div>
				</div>
			</div>
			<div class="MDLCDiv" id="MDLCDiv-FaceMix" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan face_mix"></span>
					<div id="MDLCDivTExpandDiv" style="opacity: 0;"><span class="click"></span><div class="MDLCDivTExpandDivBtn"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom">
					<div class="MDLCDBVariations">
						<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="mainDivBottomLeftBottomDivBottomInputSlider-FaceMix" type="range" min="1" max="100" value="80"></input>
					</div>
				</div>
			</div>
			<div class="MDLCDiv" id="MDLCDiv-SkinMix" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan skin_mix"></span>
					<div id="MDLCDivTExpandDiv" style="opacity: 0;"><span class="click"></span><div class="MDLCDivTExpandDivBtn"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom">
					<div class="MDLCDBVariations">
						<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="mainDivBottomLeftBottomDivBottomInputSlider-SkinMix" type="range" min="1" max="100" value="80"></input>
					</div>
				</div>
			</div>
			<div class="MDLCDiv" id="MDLCDiv-ThirdMix" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan third_mix"></span>
					<div id="MDLCDivTExpandDiv" style="opacity: 0;"><span class="click"></span><div class="MDLCDivTExpandDivBtn"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom">
					<div class="MDLCDBVariations">
						<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="mainDivBottomLeftBottomDivBottomInputSlider-ThirdMix" type="range" min="1" max="100" value="80"></input>
					</div>
				</div>
			</div>
			`;
		} else if (data.action === "PedModelInput") {
			var html = `
			<div class="MDLCDiv" id="MDLCDiv-PedModelInput" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan custom_ped"></span>
					<div id="MDLCDivTExpandDiv" style="opacity: 0;"><span class="click"></span><div class="MDLCDivTExpandDivBtn"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom">
					<div class="MDLCDBVariations">
						<input class="MDLCDivBottomInput" id="mainDivBottomLeftBottomDivBottomInput-PedModelInput" type="text" placeholder="${translations.custom_ped_input}"></input>
					</div>
				</div>
			</div>
			`;
		} else if (data.action === "Nose") {
			var html = `
			<div class="MDLCDiv" id="MDLCDiv-Nose" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan nose"></span>
					<div id="MDLCDivTExpandDiv" style="opacity: 0;"><span class="click"></span><div class="MDLCDivTExpandDivBtn"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom">
					<div class="MDLCDBVariations" style="flex-wrap: wrap; flex-direction: unset; justify-content: space-between;">
						<div class="MDLCDBVariationInputDiv">
							<span class="bone_height"></span>
							<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="NosePeak-Slider" type="range" min="1" max="100" value="80"></input>
						</div>
						<div class="MDLCDBVariationInputDiv">
							<span class="width"></span>
							<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="NoseWidth-Slider" type="range" min="1" max="100" value="80"></input>
						</div>
						<div class="MDLCDBVariationInputDiv">
							<span class="peak_length"></span>
							<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="NoseLength-Slider" type="range" min="1" max="100" value="80"></input>
						</div>
						<div class="MDLCDBVariationInputDiv">
							<span class="peak_height"></span>
							<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="NoseTip-Slider" type="range" min="1" max="100" value="80"></input>
						</div>
						<div class="MDLCDBVariationInputDiv">
							<span class="bone_twist"></span>
							<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="NoseBoneTwist-Slider" type="range" min="1" max="100" value="80"></input>
						</div>
						<div class="MDLCDBVariationInputDiv">
							<span class="peak_lowering"></span>
							<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="NoseBoneCurveness-Slider" type="range" min="1" max="100" value="80"></input>
						</div>
					</div>
				</div>
			</div>
			`;
		} else if (data.action === "Eyebrows2") {
			var html = `
			<div class="MDLCDiv" id="MDLCDiv-Eyebrows2" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan eyebrows"></span>
					<div id="MDLCDivTExpandDiv" style="opacity: 0;"><span class="click"></span><div class="MDLCDivTExpandDivBtn"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom">
					<div class="MDLCDBVariations" style="flex-wrap: wrap; flex-direction: unset; justify-content: space-between;">
						<div class="MDLCDBVariationInputDiv">
							<span class="eyebrow_depth"></span>
							<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="EyebrowDepth-Slider" type="range" min="1" max="100" value="80"></input>
						</div>
						<div class="MDLCDBVariationInputDiv">
							<span class="eyebrow_height"></span>
							<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="EyebrowHeight-Slider" type="range" min="1" max="100" value="80"></input>
						</div>
					</div>
				</div>
			</div>
			`;
		} else if (data.action === "Cheeks") {
			var html = `
			<div class="MDLCDiv" id="MDLCDiv-Cheeks" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan cheeks"></span>
					<div id="MDLCDivTExpandDiv" style="opacity: 0;"><span class="click"></span><div class="MDLCDivTExpandDivBtn"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom">
					<div class="MDLCDBVariations" style="flex-wrap: wrap; flex-direction: unset; justify-content: space-between;">
						<div class="MDLCDBVariationInputDiv">
							<span class="bone_width"></span>
							<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="CheekBoneWidth-Slider" type="range" min="1" max="100" value="80"></input>
						</div>
						<div class="MDLCDBVariationInputDiv">
							<span class="bone_height"></span>
							<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="CheekBoneHeight-Slider" type="range" min="1" max="100" value="80"></input>
						</div>
						<div class="MDLCDBVariationInputDiv" style="width: 100%;">
							<span class="bone_width"></span>
							<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="CheekBoneWidth2-Slider" type="range" min="1" max="100" value="80"></input>
						</div>
					</div>
				</div>
			</div>
			`;
		} else if (data.action === "JawBone") {
			var html = `
			<div class="MDLCDiv" id="MDLCDiv-JawBone" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan jaw_bone"></span>
					<div id="MDLCDivTExpandDiv" style="opacity: 0;"><span class="click"></span><div class="MDLCDivTExpandDivBtn"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom">
					<div class="MDLCDBVariations" style="flex-wrap: wrap; flex-direction: unset; justify-content: space-between;">
						<div class="MDLCDBVariationInputDiv">
							<span class="bone_length"></span>
							<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="JawBoneLength-Slider" type="range" min="1" max="100" value="80"></input>
						</div>
						<div class="MDLCDBVariationInputDiv">
							<span class="bone_width"></span>
							<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="JawBoneWidth-Slider" type="range" min="1" max="100" value="80"></input>
						</div>
					</div>
				</div>
			</div>
			`;
		} else if (data.action === "Chin") {
			var html = `
			<div class="MDLCDiv" id="MDLCDiv-Chin" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan chin"></span>
					<div id="MDLCDivTExpandDiv" style="opacity: 0;"><span class="click"></span><div class="MDLCDivTExpandDivBtn"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom">
					<div class="MDLCDBVariations" style="flex-wrap: wrap; flex-direction: unset; justify-content: space-between;">
						<div class="MDLCDBVariationInputDiv">
							<span class="bone_length"></span>
							<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="ChinBoneLength-Slider" type="range" min="1" max="100" value="80"></input>
						</div>
						<div class="MDLCDBVariationInputDiv">
							<span class="bone_height"></span>
							<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="ChinBoneHeight-Slider" type="range" min="1" max="100" value="80"></input>
						</div>
						<div class="MDLCDBVariationInputDiv">
							<span class="chin_cleft"></span>
							<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="ChinCleft-Slider" type="range" min="1" max="100" value="80"></input>
						</div>
						<div class="MDLCDBVariationInputDiv">
							<span class="bone_width"></span>
							<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="ChinBoneWidth-Slider" type="range" min="1" max="100" value="80"></input>
						</div>
					</div>
				</div>
			</div>
			`;
		} else if (data.action === "MiscellaneousFeatures") {
			var html = `
			<div class="MDLCDiv" id="MDLCDiv-MiscellaneousFeatures" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan misc_features"></span>
					<div id="MDLCDivTExpandDiv" style="opacity: 0;"><span class="click"></span><div class="MDLCDivTExpandDivBtn"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom">
					<div class="MDLCDBVariations" style="flex-wrap: wrap; flex-direction: unset; justify-content: space-between;">
						<div class="MDLCDBVariationInputDiv">
							<span class="lips_thickness"></span>
							<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="LipsThickness-Slider" type="range" min="1" max="100" value="80"></input>
						</div>
						<div class="MDLCDBVariationInputDiv">
							<span class="eyes_squint"></span>
							<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="EyesSquint-Slider" type="range" min="1" max="100" value="80"></input>
						</div>
						<div class="MDLCDBVariationInputDiv" style="width: 100%;">
							<span class="neck_thickness"></span>
							<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="NeckThickness-Slider" type="range" min="1" max="100" value="80"></input>
						</div>
					</div>
				</div>
			</div>
			`;
		} else {
			var html = `
			<div class="MDLCDiv" id="MDLCDiv-${data.action}" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan ${action}"></span>
					<div id="MDLCDivTExpandDiv"><span class="click"></span><div class="MDLCDivTExpandDivBtn" id="mainDivBottomLeftBottomDivTopExpandDivButton-${data.action}"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom">
					<div class="MDLCDivBottomInside" id="mainDivBottomLeftBottomDivBottom-${data.action}"></div>
				</div>
			</div>
			`;
		}
		appendHtml(document.getElementById(`MDLCenter`), html);
	});
	generalData.forEach(function(data, index) {
		variationsData[data.action] = -1;
		if (data.action === "Hairs" || data.action === "Jacket" || data.action === "Undershirt" || data.action === "Arms/Gloves" || data.action === "Pants" || data.action === "Shoes" || data.action === "Decals" || data.action === "Masks" || data.action === "Vest" || data.action === "Bag" || data.action === "Scarfs/Necklaces") {variationsData[data.action] = 0};
		if (ed.gender === "male" && data.action === "Glasses") {
			variationsData[data.action] = 0;
		}
		if (data.action === "Eyebrows") {
			variationsData[data.action] = 0;
		}
		variationTexturesData[data.action] = {};
		variationTexturesData[data.action].currentNum = 0;
		variationTexturesData[data.action + "_2"] = {};
		variationTexturesData[data.action + "_2"].currentNum = 0;
		if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}Span-ComponentVariation`)) {
			document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}Span-ComponentVariation`).innerHTML="0";
		}
		if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}Span-TextureVariation`)) {
			document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}Span-TextureVariation`).innerHTML="0";
		}
		if (data.btnClick && !expandButtonData[data.action]) {
			const button = document.getElementById(`mainDivBottomLeftBottomDivTopExpandDivButton-${data.action}`);
			button.onclick = null;
			button.onclick = (e) => {
				expandDiv(`mainDivBottomLeftBottomDivBottom-${data.action}`);
			};
		}
		if (data.btnClick2 && !expandButtonData[data.action]) {
			const button = document.getElementById(`mainDivBottomLeftBottomDivTopExpandDivButton-${data.action}`);
			button.onclick = null;
			button.onclick = (e) => {
				expandDiv2(data.action);
			};
			expandDiv2(data.action);
			expandDiv2(data.action);
		}
		expandButtonData[data.action] = true;
		if (!data.minVariationNumber) data.minVariationNumber = 0;
		// Component Variation
		if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}BtnLeft-ComponentVariation`)) {
			document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}BtnLeft-ComponentVariation`).setAttribute("onclick", `changeComponentVariation('${data.action}', '${data.minVariationNumber}', '${data.variationNumber}', 'left')`);
		}
		if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}BtnRight-ComponentVariation`)) {
			document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}BtnRight-ComponentVariation`).setAttribute("onclick", `changeComponentVariation('${data.action}', '${data.maxVariationNumber}', '${data.variationNumber}', 'right')`);
		}
		// Texture Variation
		if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}BtnLeft-TextureVariation`)) {
			document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}BtnLeft-TextureVariation`).setAttribute("onclick", `changeTextureVariation2('${data.action}', '${data.variationNumber}', 'left')`);
		}
		if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}BtnRight-TextureVariation`)) {
			document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}BtnRight-TextureVariation`).setAttribute("onclick", `changeTextureVariation2('${data.action}', '${data.variationNumber}', 'right')`);
		}
		data.data.forEach(function(cData, index) {
			let id = cData.num;
			if (data.action.includes("Color") && data.action != "EyeColor") {
				var html = `<div class="MDLCDivBDivColor" id="MDLCDivBDiv-${data.action}-${index}" style="background: rgba(${cData.r}, ${cData.g}, ${cData.b}, 255)" onclick="changeVariationColor('${data.action}', '${index}')"></div>`;
				appendHtml(document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}`), html);
				return
			}
			if (data.search === true && id === -1 || data.action === "Masks" && index === 0 || data.action === "Vest" && index === 0 || data.action === "Bag" && index === 0 || data.action === "Scarfs/Necklaces" && index === 0 || data.action === "Decals" && index === 0 || data.action === "Glasses" && index === 0) {
				var html = `
				<div class="MDLCDivBDiv MDLCDivBDivBigIMG" id="MDLCDivBDiv-${data.action}-${id}" onclick="changeVariation('${data.variationNumber}', '${cData.num}', '${data.action}')">
					<img crossOrigin="anonymous" src="files/menu/default.svg">
					<div id="mainDivBottomLeftBottomDivSpanDiv">${translations.none}</div>
				</div>
				`;
				appendHtml(document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}`), html);
				return
			}
			data.style = data.style || "";
			if (data.action === "EyeColor") {
				var html = `
				<div class="MDLCDivBDiv ${data.imgType}" id="MDLCDivBDiv-${data.action}-${id}" onclick="setPedEyeColor('${data.action}', '${cData.num}')">
					<img crossOrigin="anonymous" style="${data.style}" src="${cData.image}" onerror="this.onerror=null; this.src='files/menu/unknown.svg';">
				</div>`;
				appendHtml(document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}`), html);
				// if (!selectedComponentVariationData[data.action]) {
				// 	setPedEyeColor(data.action, cData.num);
				// }
				return
			}
			if (data.action === "FaceOne" || data.action === "SkinOne" || data.action === "FaceTwo" || data.action === "SkinTwo" || data.action === "FaceThree" || data.action === "SkinThree") {
				var html = `
				<div class="MDLCDivBDiv ${data.imgType}" id="MDLCDivBDiv-${data.action}-${id}" onclick="changeFace('${data.action}', '${cData.num}')">
					<img crossOrigin="anonymous" style="${data.style}" src="${cData.image}" onerror="this.onerror=null; this.src='files/menu/unknown.svg';">
					<div id="mainDivBottomLeftBottomDivSpanDiv">${cData.num}</div>
				</div>`;
				appendHtml(document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}`), html);
				// if (selectedComponentVariationData[data.action].num === -1) {
				// 	changeFace(data.action, cData.num);
				// }
				return
			}
			if (data.action === "FemalePeds") {
				if (ed.gender === "male" && ed.ShowAllPeds === false) {document.getElementById(data.action).style.display = "none"; return};
				var html = `
				<div class="MDLCDivBDiv ${data.imgType}" id="MDLCDivBDiv-Peds-${cData.model}" onclick="choosePed('${cData.model}')">
					<img crossOrigin="anonymous" style="${data.style}" 
						src="${cData.image}" 
						onerror="
							this.onerror = null; 
							this.src = '${cData.image2 || 'files/menu/unknown.svg'}'; 
						">
				</div>`;
				appendHtml(document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}`), html);
				if (cData.model && cData.model === ed.myPed) {
					selectedPed = cData.model;
					document.getElementById("mainDivBottomLeftBottomDivBottomInput-PedModelInput").value=selectedPed;
					document.getElementById(`MDLCDivBDiv-Peds-${selectedPed}`).classList.add("MDLCDivBDivSelected");
				}
				return
			}
			if (data.action === "MalePeds") {
				if (ed.gender === "female" && ed.ShowAllPeds === false) {document.getElementById(data.action).style.display = "none"; return};
				var html = `
				<div class="MDLCDivBDiv ${data.imgType}" id="MDLCDivBDiv-Peds-${cData.model}" onclick="choosePed('${cData.model}')">
					<img crossOrigin="anonymous" style="${data.style}" 
						src="${cData.image}" 
						onerror="
							this.onerror = null; 
							this.src = '${cData.image2 || 'files/menu/unknown.svg'}'; 
						">
				</div>`;
				appendHtml(document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}`), html);
				if (cData.model && cData.model === ed.myPed) {
					selectedPed = cData.model;
					document.getElementById("mainDivBottomLeftBottomDivBottomInput-PedModelInput").value=selectedPed;
					document.getElementById(`MDLCDivBDiv-Peds-${selectedPed}`).classList.add("MDLCDivBDivSelected");
				}
				return
			}
			let bottomSpan = index;
			if (bottomSpan === 0) {
				bottomSpan = translations.none;
			} 
			if (data.action === "Hat" || data.action === "Glasses" || data.action === "Earrings" || data.action === "Watches" || data.action === "Bracelets") {
				var html = `
				<div class="MDLCDivBDiv ${data.imgType}" id="MDLCDivBDiv-${data.action}-${id}" onclick="changePropVariation('${data.variationNumber}', '${id}', '${data.action}')">
					<img crossOrigin="anonymous" style="${data.style}" src="${cData.image}" onerror="this.onerror=null; this.src='files/menu/unknown.svg'; this.style='width: 4vw;';">
					<div id="mainDivBottomLeftBottomDivSpanDiv">${bottomSpan}</div>
				</div>`;
				appendHtml(document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}`), html);
				if (!selectedComponentVariationData[data.action]) {
					changePropVariation(data.variationNumber, variationsData[data.action], data.action);
				}
				return
			}
			var html = `
			<div class="MDLCDivBDiv ${data.imgType}" id="MDLCDivBDiv-${data.action}-${id}" onclick="changeVariation('${data.variationNumber}', '${id}', '${data.action}')">
				<img crossOrigin="anonymous" style="${data.style}" src="${cData.image}" onerror="this.onerror=null; this.src='files/menu/unknown.svg'; this.style='width: 4vw;';">
				<div id="mainDivBottomLeftBottomDivSpanDiv">${bottomSpan}</div>
			</div>`;
			appendHtml(document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}`), html);
		});
		if (data.currentDrawableVariation !== null || data.currentDrawableVariation !== undefined) {
			changeVariation(data.variationNumber, data.currentDrawableVariation, data.action, data.currentTextureDrawableVariation);
		}
		if (data.currentTextureDrawableVariation !== null || data.currentTextureDrawableVariation !== undefined) {
			changeTextureVariation(data.variationNumber, data.currentTextureDrawableVariation, data.action);
		}
		if (data.action === "FacialHairs" || data.action === "Eyebrows" || data.action === "Blemishes" || data.action === "Ageing" || data.action === "Complexion" || data.action === "SunDamage" || data.action === "MolesFreckles" || data.action === "ChestHair" || data.action === "BodyBlemishes" || data.action === "AddBodyBlemishes") {
			if (data.currentDrawableVariationOpacity) {
				document.getElementById(`${data.action}-OpacitySlider`).value = data.currentDrawableVariationOpacity * 100;
				let skinData = [
					{name: "FacialHairs", mainName: "FacialHairs", variationNumber: 1},
					{name: "Eyebrows", mainName: "Eyebrows", variationNumber: 2},
					{name: "Blemishes", mainName: "Blemishes", variationNumber: 0},
					{name: "Ageing", mainName: "Ageing", variationNumber: 3},
					{name: "Complexion", mainName: "Complexion", variationNumber: 6},
					{name: "SunDamage", mainName: "SunDamage", variationNumber: 7},
					{name: "MolesFreckles", mainName: "MolesFreckles", variationNumber: 9},
					{name: "ChestHair", mainName: "ChestHair", variationNumber: 10},
					{name: "BodyBlemishes", mainName: "BodyBlemishes", variationNumber: 11},
					{name: "AddBodyBlemishes", mainName: "AddBodyBlemishes", variationNumber: 12}
				];
				skinData.forEach(function(sdata, index) {
					if (!selectedComponentVariationData[sdata.mainName]) {return};
					if (!variationTexturesData[sdata.mainName]) {return};
					post({action: "changeHeadOverlay", action2: sdata.mainName, num1: Number(sdata.variationNumber), num2: selectedComponentVariationData[sdata.mainName].num, num3: variationTexturesData[sdata.mainName].currentNum, opacity: document.getElementById(`${sdata.name}-OpacitySlider`).value});
				});
				skinData.forEach(function(data, index) {
					if (!document.getElementById(`${data.name}-OpacitySlider`)) return;
					document.getElementById(`${data.name}-OpacitySlider`).addEventListener('input', function() {
						if (!selectedComponentVariationData[data.mainName]) {return};
						if (!variationTexturesData[data.mainName]) {return};
						post({action: "changeHeadOverlay", action2: data.mainName, num1: Number(data.variationNumber), num2: selectedComponentVariationData[data.mainName].num, num3: variationTexturesData[data.mainName].currentNum, opacity: document.getElementById(`${data.name}-OpacitySlider`).value});
					});
				});
			}
		}
		if (data.action.includes("Color") && data.action != "EyeColor") {
			if (data.currentDrawableVariation !== null && data.currentDrawableVariation !== undefined) {
				changeVariationColor(data.action, data.currentDrawableVariation)
			}
		}
		if (data.action === "EyeColor") {
			if (data.currentDrawableVariation !== null || data.currentDrawableVariation !== undefined) {
				setPedEyeColor(data.action, data.currentDrawableVariation);
			}
		}
		if (data.action === "FaceMix") {
			document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-FaceMix").value = data.value * 10;
			post({
				action: "changeFace",
				firstShape: selectedComponentVariationData["FaceOne"].num,
				secondShape: selectedComponentVariationData["FaceTwo"].num,
				thirdShape: selectedComponentVariationData["FaceThree"].num,
				firstSkin: selectedComponentVariationData["SkinOne"].num,
				secondSkin: selectedComponentVariationData["SkinTwo"].num,
				thirdSkin: selectedComponentVariationData["SkinThree"].num,
				shapeMix: document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-FaceMix").value,
				skinMix: document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-SkinMix").value,
				thirdMix: document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-ThirdMix").value,
			});
		}
		if (data.action === "SkinMix") {
			document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-SkinMix").value = data.value * 10;
			post({
				action: "changeFace",
				firstShape: selectedComponentVariationData["FaceOne"].num,
				secondShape: selectedComponentVariationData["FaceTwo"].num,
				thirdShape: selectedComponentVariationData["FaceThree"].num,
				firstSkin: selectedComponentVariationData["SkinOne"].num,
				secondSkin: selectedComponentVariationData["SkinTwo"].num,
				thirdSkin: selectedComponentVariationData["SkinThree"].num,
				shapeMix: document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-FaceMix").value,
				skinMix: document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-SkinMix").value,
				thirdMix: document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-ThirdMix").value,
			});
		}
		if (data.action === "ThirdMix") {
			document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-ThirdMix").value = data.value * 10;
			post({
				action: "changeFace",
				firstShape: selectedComponentVariationData["FaceOne"].num,
				secondShape: selectedComponentVariationData["FaceTwo"].num,
				thirdShape: selectedComponentVariationData["FaceThree"].num,
				firstSkin: selectedComponentVariationData["SkinOne"].num,
				secondSkin: selectedComponentVariationData["SkinTwo"].num,
				thirdSkin: selectedComponentVariationData["SkinThree"].num,
				shapeMix: document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-FaceMix").value,
				skinMix: document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-SkinMix").value,
				thirdMix: document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-ThirdMix").value,
			});
		}
		if (data.action === "FaceFeatures") {
			let faceFeatData = [
				{name: "NoseWidth", variationNumber: 0},
				{name: "NosePeak", variationNumber: 1},
				{name: "NoseLength", variationNumber: 2},
				{name: "NoseBoneCurveness", variationNumber: 3},
				{name: "NoseTip", variationNumber: 4},
				{name: "NoseBoneTwist", variationNumber: 5},
				{name: "EyebrowHeight", variationNumber: 6},
				{name: "EyebrowDepth", variationNumber: 7},
				{name: "CheekBoneHeight", variationNumber: 8},
				{name: "CheekBoneWidth", variationNumber: 9},
				{name: "CheekBoneWidth2", variationNumber: 10},
				{name: "EyesSquint", variationNumber: 11},
				{name: "LipsThickness", variationNumber: 12},
				{name: "JawBoneLength", variationNumber: 13},
				{name: "JawBoneWidth", variationNumber: 14},
				{name: "ChinBoneHeight", variationNumber: 15},
				{name: "ChinBoneLength", variationNumber: 16},
				{name: "ChinBoneWidth", variationNumber: 17},
				{name: "ChinCleft", variationNumber: 18},
				{name: "NeckThickness", variationNumber: 19}
			];
			faceFeatData.forEach(function(fdata, index) {
				document.getElementById(`${fdata.name}-Slider`).value = data.data2[fdata.name] * 100;
				post({action: "changeFaceFeature", name: fdata.name, num1: fdata.variationNumber, value: document.getElementById(`${fdata.name}-Slider`).value / 100});
			});
		}
		if (data.action === "mblOpacity") {
			let makeupData = [
				{name: "Makeup", variationNumber: 4},
				{name: "Blush", variationNumber: 5},
				{name: "Lipstick", variationNumber: 8}
			];
			makeupData.forEach(function(mdata, index) {
				if (!selectedComponentVariationData[mdata.name]) {return};
				if (!variationTexturesData[mdata.name]) {return};
				document.getElementById(`${mdata.name}-OpacitySlider`).value = data[mdata.name + "Opacity"] * 100;
				post({action: "changeHeadOverlay", action2: mdata.name, num1: Number(mdata.variationNumber), num2: selectedComponentVariationData[mdata.name].num, num3: variationTexturesData[mdata.name].currentNum, opacity: document.getElementById(`${mdata.name}-OpacitySlider`).value});
			});
		}
		document.querySelectorAll('.mainDivBottomLeftBottomDivBottomInputSlider').forEach(slider => {
			const updateSliderBackground = (slider) => {
				const value = slider.value;
				const max = slider.max;
				const percentage = (value / max) * 100;
				slider.style.background = `linear-gradient(90deg, #00FFEA ${percentage}%, rgba(255, 255, 255, 0) ${percentage}%), radial-gradient(124.16% 111.18% at 50% 50%, rgba(255, 255, 255, 0.15) 0%, rgba(255, 255, 255, 0.00) 100%)`;
			};
			updateSliderBackground(slider);
			slider.addEventListener('input', function() {
				updateSliderBackground(this);
			});
		});
		document.querySelectorAll('.mainDivBottomLeftBottomDivBottomInputSlider2').forEach(slider => {
			const updateSliderBackground = (slider) => {
				const value = slider.value;
				const max = slider.max;
				const percentage = (value / max) * 100;
				slider.style.background = `linear-gradient(90deg, #00FFEA ${percentage}%, rgba(255, 255, 255, 0) ${percentage}%), radial-gradient(124.16% 111.18% at 50% 50%, rgba(255, 255, 255, 0.15) 0%, rgba(255, 255, 255, 0.00) 100%)`;
			};
			updateSliderBackground(slider);
			slider.addEventListener('input', function() {
				updateSliderBackground(this);
			});
		});
		// Face Features
		let faceFeatData = [
			{name: "NoseWidth", variationNumber: 0},
			{name: "NosePeak", variationNumber: 1},
			{name: "NoseLength", variationNumber: 2},
			{name: "NoseBoneCurveness", variationNumber: 3},
			{name: "NoseTip", variationNumber: 4},
			{name: "NoseBoneTwist", variationNumber: 5},
			{name: "EyebrowHeight", variationNumber: 6},
			{name: "EyebrowDepth", variationNumber: 7},
			{name: "CheekBoneHeight", variationNumber: 8},
			{name: "CheekBoneWidth", variationNumber: 9},
			{name: "CheekBoneWidth2", variationNumber: 10},
			{name: "EyesSquint", variationNumber: 11},
			{name: "LipsThickness", variationNumber: 12},
			{name: "JawBoneLength", variationNumber: 13},
			{name: "JawBoneWidth", variationNumber: 14},
			{name: "ChinBoneHeight", variationNumber: 15},
			{name: "ChinBoneLength", variationNumber: 16},
			{name: "ChinBoneWidth", variationNumber: 17},
			{name: "ChinCleft", variationNumber: 18},
			{name: "NeckThickness", variationNumber: 19}
		];
		faceFeatData.forEach(function(data, index) {
			document.getElementById(`${data.name}-Slider`).addEventListener('input', function() {
				post({action: "changeFaceFeature", name: data.name, num1: data.variationNumber, value: document.getElementById(`${data.name}-Slider`).value / 100});
			});
		});
		// Face Mixers
		document.getElementById(`mainDivBottomLeftBottomDivBottomInputSlider-FaceMix`).addEventListener('input', function() {
			post({
				action: "changeFace",
				firstShape: selectedComponentVariationData["FaceOne"].num,
				secondShape: selectedComponentVariationData["FaceTwo"].num,
				thirdShape: selectedComponentVariationData["FaceThree"].num,
				firstSkin: selectedComponentVariationData["SkinOne"].num,
				secondSkin: selectedComponentVariationData["SkinTwo"].num,
				thirdSkin: selectedComponentVariationData["SkinThree"].num,
				shapeMix: document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-FaceMix").value,
				skinMix: document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-SkinMix").value,
				thirdMix: document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-ThirdMix").value,
			});
		});
		document.getElementById(`mainDivBottomLeftBottomDivBottomInputSlider-SkinMix`).addEventListener('input', function() {
			post({
				action: "changeFace",
				firstShape: selectedComponentVariationData["FaceOne"].num,
				secondShape: selectedComponentVariationData["FaceTwo"].num,
				thirdShape: selectedComponentVariationData["FaceThree"].num,
				firstSkin: selectedComponentVariationData["SkinOne"].num,
				secondSkin: selectedComponentVariationData["SkinTwo"].num,
				thirdSkin: selectedComponentVariationData["SkinThree"].num,
				shapeMix: document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-FaceMix").value,
				skinMix: document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-SkinMix").value,
				thirdMix: document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-ThirdMix").value,
			});
		});
		document.getElementById(`mainDivBottomLeftBottomDivBottomInputSlider-ThirdMix`).addEventListener('input', function() {
			post({
				action: "changeFace",
				firstShape: selectedComponentVariationData["FaceOne"].num,
				secondShape: selectedComponentVariationData["FaceTwo"].num,
				thirdShape: selectedComponentVariationData["FaceThree"].num,
				firstSkin: selectedComponentVariationData["SkinOne"].num,
				secondSkin: selectedComponentVariationData["SkinTwo"].num,
				thirdSkin: selectedComponentVariationData["SkinThree"].num,
				shapeMix: document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-FaceMix").value,
				skinMix: document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-SkinMix").value,
				thirdMix: document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-ThirdMix").value,
			});
		});
		expandButtonData[data.action] = null;
	});
	document.getElementById("mainDivBottomLeftBottomDivBottomInput-PedModelInput").addEventListener("change", (event) => {
		post({action: "loadPed", model: event.target.value});
		if (document.getElementById(`MDLCDivBDiv-Peds-${event.target.value}`)) {
			choosePed(event.target.value);
		}
	});
	for (var key in translations) {
		if (translations.hasOwnProperty(key)) {
			var elements = document.getElementsByClassName(key);
			for (var i = 0; i < elements.length; i++) {
				elements[i].innerHTML = translations[key];
			}
		}
	}
}

function openCreateCharMenu(gender) {
	document.getElementById("MDLCenter").innerHTML="";
	generalData.forEach(function(data, index) {
		let display = "flex";
		if (!clothStoreCategories[data.action + "_" + selectedPage2]) display = "none";
		let action = formatString(data.action);
		if (action.includes("highlight_color")) action = "highlight_color";
		if (action.includes("first_")) action = "first_color";
		if (action.includes("second_")) action = "second_color";
		if (data.data && JSON.stringify(data.data) === "[]" && !data.passDataControl) return;
		if (gender === "female") {
			if (data.action === "FacialHairs" || data.action === "FacialHairsColors" || data.action === "FacialHairsHighlightColors") {
				display = "none";
			}
		}
		if (data.action.includes("Color")) {
			var html = `
			<div class="MDLCDiv" id="MDLCDiv-${data.action}" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan ${action}"></span>
					<div id="MDLCDivTExpandDiv"><span class="click"></span><div class="MDLCDivTExpandDivBtn" id="mainDivBottomLeftBottomDivTopExpandDivButton-${data.action}"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom" id="MDLCDivBottom-${data.action}">
					<div class="MDLCDivBottomInside" id="mainDivBottomLeftBottomDivBottom-${data.action}"></div>
				</div>
			</div>
			`;
		} else if (data.currentDrawableVariationOpacity || data.action === "Blush" || data.action === "Lipstick" || data.action === "Makeup" || data.action === "FacialHairs" || data.action === "Eyebrows" || data.action === "Blemishes" || data.action === "Ageing" || data.action === "Complexion" || data.action === "SunDamage" || data.action === "MolesFreckles" || data.action === "ChestHair" || data.action === "BodyBlemishes" || data.action === "AddBodyBlemishes") {
			var html = `
			<div class="MDLCDiv" id="MDLCDiv-${data.action}" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan ${action}"></span>
					<div id="MDLCDivTExpandDiv"><span class="click"></span><div class="MDLCDivTExpandDivBtn" id="mainDivBottomLeftBottomDivTopExpandDivButton-${data.action}"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom">
					<div class="MDLCDivBottomInside" id="mainDivBottomLeftBottomDivBottom-${data.action}"></div>
					<div class="MDLCDBVariations">
						<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="${data.action}-OpacitySlider" type="range" min="1" max="100" value="80"></input>
					</div>
				</div>
			</div>
			`;
		} else if (data.action === "Hairs") {
			var html = `
			<div class="MDLCDiv" id="MDLCDiv-${data.action}" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan ${action}"></span>
					<div id="MDLCDivTExpandDiv"><span class="click"></span><div class="MDLCDivTExpandDivBtn" id="mainDivBottomLeftBottomDivTopExpandDivButton-${data.action}"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom">
					<div class="MDLCDivBottomInside" id="mainDivBottomLeftBottomDivBottom-${data.action}"></div>
				</div>
			</div>
			`;
		} else if (data.action === "HairFade") {
			var html = `
			<div class="MDLCDiv" id="MDLCDiv-${data.action}" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan">${translations.hair_fade}</span>
					<div id="MDLCDivTExpandDiv" style="opacity: 0;"><span class="click"></span><div class="MDLCDivTExpandDivBtn"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom">
					<div class="MDLCDBVariations">
						<div class="MDLCDBVariationDiv2">
							<div class="MDLCDBVDBtn2" onclick="changeHairFade('left')"><i class="fa-regular fa-chevron-left"></i></div>
							<span id="hairFadeNumSpan">0</span>
							<div class="MDLCDBVDBtn2" onclick="changeHairFade('right')"><i class="fa-regular fa-chevron-right"></i></div>
						</div>
					</div>
				</div>
			</div>
			`;
		} else if (data.action === "HairTexture") {
			var html = `
			<div class="MDLCDiv" id="MDLCDiv-${data.action}" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan">${translations.hair_texture}</span>
					<div id="MDLCDivTExpandDiv" style="opacity: 0;"><span class="click"></span><div class="MDLCDivTExpandDivBtn"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom">
					<div class="MDLCDBVariations">
						<div class="MDLCDBVariationDiv2">
							<div class="MDLCDBVDBtn2" onclick="changeHairTexture('left')"><i class="fa-regular fa-chevron-left"></i></div>
							<span id="hairTextureNumSpan">0</span>
							<div class="MDLCDBVDBtn2" onclick="changeHairTexture('right')"><i class="fa-regular fa-chevron-right"></i></div>
						</div>
					</div>
				</div>
			</div>
			`;
		} else if (data.action === "FemalePeds" || data.action === "MalePeds") {
			var html = `
			<div class="MDLCDiv" id="MDLCDiv-${data.action}" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan ${action}"></span>
					<div id="MDLCDivTExpandDiv"><span class="click"></span><div class="MDLCDivTExpandDivBtn" id="mainDivBottomLeftBottomDivTopExpandDivButton-${data.action}"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom">
					<div class="MDLCDivBottomInside" id="mainDivBottomLeftBottomDivBottom-${data.action}"></div>
				</div>
			</div>
			`;
		} else if (data.minVariationNumber !== undefined) {
			var html = `
			<div class="MDLCDiv" id="MDLCDiv-${data.action}" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan ${action}"></span>
					<div id="MDLCDivTExpandDiv"><span class="click"></span><div class="MDLCDivTExpandDivBtn" id="mainDivBottomLeftBottomDivTopExpandDivButton-${data.action}"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom">
					<div class="MDLCDivBottomInside" id="mainDivBottomLeftBottomDivBottom-${data.action}"></div>
					<div class="MDLCDBVariations">
						<div class="MDLCDBVariationDiv">
							<div class="MDLCDBVDBtn" id="mainDivBottomLeftBottomDivBottom-${data.action}BtnLeft-ComponentVariation"><i class="fa-regular fa-chevron-left"></i></div>
							<span id="mainDivBottomLeftBottomDivBottom-${data.action}Span-ComponentVariation"></span>
							<div class="MDLCDBVDBtn" id="mainDivBottomLeftBottomDivBottom-${data.action}BtnRight-ComponentVariation"><i class="fa-regular fa-chevron-right"></i></div>
						</div>
						<div class="MDLCDBVariationDiv">
							<div class="MDLCDBVDBtn" id="mainDivBottomLeftBottomDivBottom-${data.action}BtnLeft-TextureVariation"><i class="fa-regular fa-chevron-left"></i></div>
							<span id="mainDivBottomLeftBottomDivBottom-${data.action}Span-TextureVariation"></span>
							<div class="MDLCDBVDBtn" id="mainDivBottomLeftBottomDivBottom-${data.action}BtnRight-TextureVariation"><i class="fa-regular fa-chevron-right"></i></div>
						</div>
					</div>
				</div>
			</div>
			`;
		} else if (data.action === "SkinThree") {
			var html = `
			<div class="MDLCDiv" id="MDLCDiv-${data.action}" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan ${action}"></span>
					<div id="MDLCDivTExpandDiv"><span class="click"></span><div class="MDLCDivTExpandDivBtn" id="mainDivBottomLeftBottomDivTopExpandDivButton-${data.action}"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom">
					<div class="MDLCDivBottomInside" id="mainDivBottomLeftBottomDivBottom-${data.action}"></div>
				</div>
			</div>
			<div class="MDLCDiv" id="MDLCDiv-FaceMix" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan face_mix"></span>
					<div id="MDLCDivTExpandDiv" style="opacity: 0;"><span class="click"></span><div class="MDLCDivTExpandDivBtn"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom">
					<div class="MDLCDBVariations">
						<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="mainDivBottomLeftBottomDivBottomInputSlider-FaceMix" type="range" min="1" max="100" value="80"></input>
					</div>
				</div>
			</div>
			<div class="MDLCDiv" id="MDLCDiv-SkinMix" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan skin_mix"></span>
					<div id="MDLCDivTExpandDiv" style="opacity: 0;"><span class="click"></span><div class="MDLCDivTExpandDivBtn"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom">
					<div class="MDLCDBVariations">
						<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="mainDivBottomLeftBottomDivBottomInputSlider-SkinMix" type="range" min="1" max="100" value="80"></input>
					</div>
				</div>
			</div>
			<div class="MDLCDiv" id="MDLCDiv-ThirdMix" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan third_mix"></span>
					<div id="MDLCDivTExpandDiv" style="opacity: 0;"><span class="click"></span><div class="MDLCDivTExpandDivBtn"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom">
					<div class="MDLCDBVariations">
						<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="mainDivBottomLeftBottomDivBottomInputSlider-ThirdMix" type="range" min="1" max="100" value="80"></input>
					</div>
				</div>
			</div>
			`;
		} else if (data.action === "PedModelInput") {
			var html = `
			<div class="MDLCDiv" id="MDLCDiv-PedModelInput" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan custom_ped"></span>
					<div id="MDLCDivTExpandDiv" style="opacity: 0;"><span class="click"></span><div class="MDLCDivTExpandDivBtn"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom">
					<div class="MDLCDBVariations">
						<input class="MDLCDivBottomInput" id="mainDivBottomLeftBottomDivBottomInput-PedModelInput" type="text" placeholder="${translations.custom_ped_input}"></input>
					</div>
				</div>
			</div>
			`;
		} else if (data.action === "Nose") {
			var html = `
			<div class="MDLCDiv" id="MDLCDiv-Nose" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan nose"></span>
					<div id="MDLCDivTExpandDiv" style="opacity: 0;"><span class="click"></span><div class="MDLCDivTExpandDivBtn"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom">
					<div class="MDLCDBVariations" style="flex-wrap: wrap; flex-direction: unset; justify-content: space-between;">
						<div class="MDLCDBVariationInputDiv">
							<span class="bone_height"></span>
							<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="NosePeak-Slider" type="range" min="1" max="100" value="80"></input>
						</div>
						<div class="MDLCDBVariationInputDiv">
							<span class="width"></span>
							<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="NoseWidth-Slider" type="range" min="1" max="100" value="80"></input>
						</div>
						<div class="MDLCDBVariationInputDiv">
							<span class="peak_length"></span>
							<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="NoseLength-Slider" type="range" min="1" max="100" value="80"></input>
						</div>
						<div class="MDLCDBVariationInputDiv">
							<span class="peak_height"></span>
							<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="NoseTip-Slider" type="range" min="1" max="100" value="80"></input>
						</div>
						<div class="MDLCDBVariationInputDiv">
							<span class="bone_twist"></span>
							<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="NoseBoneTwist-Slider" type="range" min="1" max="100" value="80"></input>
						</div>
						<div class="MDLCDBVariationInputDiv">
							<span class="peak_lowering"></span>
							<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="NoseBoneCurveness-Slider" type="range" min="1" max="100" value="80"></input>
						</div>
					</div>
				</div>
			</div>
			`;
		} else if (data.action === "Eyebrows2") {
			var html = `
			<div class="MDLCDiv" id="MDLCDiv-Eyebrows2" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan eyebrows"></span>
					<div id="MDLCDivTExpandDiv" style="opacity: 0;"><span class="click"></span><div class="MDLCDivTExpandDivBtn"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom">
					<div class="MDLCDBVariations" style="flex-wrap: wrap; flex-direction: unset; justify-content: space-between;">
						<div class="MDLCDBVariationInputDiv">
							<span class="eyebrow_depth"></span>
							<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="EyebrowDepth-Slider" type="range" min="1" max="100" value="80"></input>
						</div>
						<div class="MDLCDBVariationInputDiv">
							<span class="eyebrow_height"></span>
							<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="EyebrowHeight-Slider" type="range" min="1" max="100" value="80"></input>
						</div>
					</div>
				</div>
			</div>
			`;
		} else if (data.action === "Cheeks") {
			var html = `
			<div class="MDLCDiv" id="MDLCDiv-Cheeks" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan cheeks"></span>
					<div id="MDLCDivTExpandDiv" style="opacity: 0;"><span class="click"></span><div class="MDLCDivTExpandDivBtn"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom">
					<div class="MDLCDBVariations" style="flex-wrap: wrap; flex-direction: unset; justify-content: space-between;">
						<div class="MDLCDBVariationInputDiv">
							<span class="bone_width"></span>
							<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="CheekBoneWidth-Slider" type="range" min="1" max="100" value="80"></input>
						</div>
						<div class="MDLCDBVariationInputDiv">
							<span class="bone_height"></span>
							<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="CheekBoneHeight-Slider" type="range" min="1" max="100" value="80"></input>
						</div>
						<div class="MDLCDBVariationInputDiv" style="width: 100%;">
							<span class="bone_width"></span>
							<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="CheekBoneWidth2-Slider" type="range" min="1" max="100" value="80"></input>
						</div>
					</div>
				</div>
			</div>
			`;
		} else if (data.action === "JawBone") {
			var html = `
			<div class="MDLCDiv" id="MDLCDiv-JawBone" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan jaw_bone"></span>
					<div id="MDLCDivTExpandDiv" style="opacity: 0;"><span class="click"></span><div class="MDLCDivTExpandDivBtn"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom">
					<div class="MDLCDBVariations" style="flex-wrap: wrap; flex-direction: unset; justify-content: space-between;">
						<div class="MDLCDBVariationInputDiv">
							<span class="bone_length"></span>
							<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="JawBoneLength-Slider" type="range" min="1" max="100" value="80"></input>
						</div>
						<div class="MDLCDBVariationInputDiv">
							<span class="bone_width"></span>
							<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="JawBoneWidth-Slider" type="range" min="1" max="100" value="80"></input>
						</div>
					</div>
				</div>
			</div>
			`;
		} else if (data.action === "Chin") {
			var html = `
			<div class="MDLCDiv" id="MDLCDiv-Chin" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan chin"></span>
					<div id="MDLCDivTExpandDiv" style="opacity: 0;"><span class="click"></span><div class="MDLCDivTExpandDivBtn"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom">
					<div class="MDLCDBVariations" style="flex-wrap: wrap; flex-direction: unset; justify-content: space-between;">
						<div class="MDLCDBVariationInputDiv">
							<span class="bone_length"></span>
							<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="ChinBoneLength-Slider" type="range" min="1" max="100" value="80"></input>
						</div>
						<div class="MDLCDBVariationInputDiv">
							<span class="bone_height"></span>
							<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="ChinBoneHeight-Slider" type="range" min="1" max="100" value="80"></input>
						</div>
						<div class="MDLCDBVariationInputDiv">
							<span class="chin_cleft"></span>
							<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="ChinCleft-Slider" type="range" min="1" max="100" value="80"></input>
						</div>
						<div class="MDLCDBVariationInputDiv">
							<span class="bone_width"></span>
							<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="ChinBoneWidth-Slider" type="range" min="1" max="100" value="80"></input>
						</div>
					</div>
				</div>
			</div>
			`;
		} else if (data.action === "MiscellaneousFeatures") {
			var html = `
			<div class="MDLCDiv" id="MDLCDiv-MiscellaneousFeatures" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan misc_features"></span>
					<div id="MDLCDivTExpandDiv" style="opacity: 0;"><span class="click"></span><div class="MDLCDivTExpandDivBtn"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom">
					<div class="MDLCDBVariations" style="flex-wrap: wrap; flex-direction: unset; justify-content: space-between;">
						<div class="MDLCDBVariationInputDiv">
							<span class="lips_thickness"></span>
							<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="LipsThickness-Slider" type="range" min="1" max="100" value="80"></input>
						</div>
						<div class="MDLCDBVariationInputDiv">
							<span class="eyes_squint"></span>
							<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="EyesSquint-Slider" type="range" min="1" max="100" value="80"></input>
						</div>
						<div class="MDLCDBVariationInputDiv" style="width: 100%;">
							<span class="neck_thickness"></span>
							<input class="mainDivBottomLeftBottomDivBottomInputSlider2" id="NeckThickness-Slider" type="range" min="1" max="100" value="80"></input>
						</div>
					</div>
				</div>
			</div>
			`;
		} else {
			var html = `
			<div class="MDLCDiv" id="MDLCDiv-${data.action}" style="display: ${display}">
				<div class="MDLCDivTop">
					<span class="MDLCDivTopSpan ${action}"></span>
					<div id="MDLCDivTExpandDiv"><span class="click"></span><div class="MDLCDivTExpandDivBtn" id="mainDivBottomLeftBottomDivTopExpandDivButton-${data.action}"><i class="fa-solid fa-chevron-down" style="color: #FFF; opacity: 0.73; margin-top: 19.4%;"></i></div></div>
				</div>
				<div class="MDLCDivBottom">
					<div class="MDLCDivBottomInside" id="mainDivBottomLeftBottomDivBottom-${data.action}"></div>
				</div>
			</div>
			`;
		}
		appendHtml(document.getElementById(`MDLCenter`), html);
	});
	generalData.forEach(function(data, index) {
		variationsData[data.action] = -1;
		if (data.action === "Hairs" || data.action === "Jacket" || data.action === "Undershirt" || data.action === "Arms/Gloves" || data.action === "Pants" || data.action === "Shoes" || data.action === "Decals" || data.action === "Masks" || data.action === "Vest" || data.action === "Bag" || data.action === "Scarfs/Necklaces") {variationsData[data.action] = 0};
		if (ed.gender === "male" && data.action === "Glasses") {
			variationsData[data.action] = 0;
		}
		if (data.action === "Eyebrows") {
			variationsData[data.action] = 0;
		}
		variationTexturesData[data.action] = {};
		variationTexturesData[data.action].currentNum = 0;
		variationTexturesData[data.action + "_2"] = {};
		variationTexturesData[data.action + "_2"].currentNum = 0;
		if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}Span-ComponentVariation`)) {
			document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}Span-ComponentVariation`).innerHTML="0";
		}
		if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}Span-TextureVariation`)) {
			document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}Span-TextureVariation`).innerHTML="0";
		}
		if (data.btnClick && !expandButtonData[data.action]) {
			const button = document.getElementById(`mainDivBottomLeftBottomDivTopExpandDivButton-${data.action}`);
			button.onclick = null;
			button.onclick = (e) => {
				expandDiv(`mainDivBottomLeftBottomDivBottom-${data.action}`);
			};
		}
		if (data.btnClick2 && !expandButtonData[data.action]) {
			const button = document.getElementById(`mainDivBottomLeftBottomDivTopExpandDivButton-${data.action}`);
			button.onclick = null;
			button.onclick = (e) => {
				expandDiv2(data.action);
			};
			expandDiv2(data.action);
			expandDiv2(data.action);
		}
		expandButtonData[data.action] = true;
		if (!data.minVariationNumber) data.minVariationNumber = 0;
		// Component Variation
		if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}BtnLeft-ComponentVariation`)) {
			document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}BtnLeft-ComponentVariation`).setAttribute("onclick", `changeComponentVariation('${data.action}', '${data.minVariationNumber}', '${data.variationNumber}', 'left')`);
		}
		if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}BtnRight-ComponentVariation`)) {
			document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}BtnRight-ComponentVariation`).setAttribute("onclick", `changeComponentVariation('${data.action}', '${data.maxVariationNumber}', '${data.variationNumber}', 'right')`);
		}
		// Texture Variation
		if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}BtnLeft-TextureVariation`)) {
			document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}BtnLeft-TextureVariation`).setAttribute("onclick", `changeTextureVariation2('${data.action}', '${data.variationNumber}', 'left')`);
		}
		if (document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}BtnRight-TextureVariation`)) {
			document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}BtnRight-TextureVariation`).setAttribute("onclick", `changeTextureVariation2('${data.action}', '${data.variationNumber}', 'right')`);
		}
		data.data.forEach(function(cData, index) {
			let id = cData.num;
			if (data.action.includes("Color") && data.action != "EyeColor") {
				var html = `<div class="MDLCDivBDivColor" id="MDLCDivBDiv-${data.action}-${index}" style="background: rgba(${cData.r}, ${cData.g}, ${cData.b}, 255)" onclick="changeVariationColor('${data.action}', '${index}')"></div>`;
				appendHtml(document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}`), html);
				return
			}
			if (data.search === true && id === -1 || data.action === "Masks" && index === 0 || data.action === "Vest" && index === 0 || data.action === "Bag" && index === 0 || data.action === "Scarfs/Necklaces" && index === 0 || data.action === "Decals" && index === 0 || data.action === "Glasses" && index === 0) {
				var html = `
				<div class="MDLCDivBDiv MDLCDivBDivBigIMG" id="MDLCDivBDiv-${data.action}-${id}" onclick="changeVariation('${data.variationNumber}', '${cData.num}', '${data.action}')">
					<img crossOrigin="anonymous" src="files/menu/default.svg">
					<div id="mainDivBottomLeftBottomDivSpanDiv">${translations.none}</div>
				</div>
				`;
				appendHtml(document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}`), html);
				return
			}
			data.style = data.style || "";
			if (data.action === "EyeColor") {
				var html = `
				<div class="MDLCDivBDiv ${data.imgType}" id="MDLCDivBDiv-${data.action}-${id}" onclick="setPedEyeColor('${data.action}', '${cData.num}')">
					<img crossOrigin="anonymous" style="${data.style}" src="${cData.image}" onerror="this.onerror=null; this.src='files/menu/unknown.svg';">
				</div>`;
				appendHtml(document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}`), html);
				if (!selectedComponentVariationData[data.action]) {
					setPedEyeColor(data.action, cData.num);
				}
				return
			}
			if (data.action === "FaceOne" || data.action === "SkinOne" || data.action === "FaceTwo" || data.action === "SkinTwo" || data.action === "FaceThree" || data.action === "SkinThree") {
				var html = `
				<div class="MDLCDivBDiv ${data.imgType}" id="MDLCDivBDiv-${data.action}-${id}" onclick="changeFace('${data.action}', '${cData.num}')">
					<img crossOrigin="anonymous" style="${data.style}" src="${cData.image}" onerror="this.onerror=null; this.src='files/menu/unknown.svg';">
					<div id="mainDivBottomLeftBottomDivSpanDiv">${cData.num}</div>
				</div>`;
				appendHtml(document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}`), html);
				if (selectedComponentVariationData[data.action].num === -1) {
					changeFace(data.action, cData.num);
				}
				return
			}
			if (data.action === "FemalePeds") {
				if (ed.gender === "male" && ed.ShowAllPeds === false) {document.getElementById(data.action).style.display = "none"; return};
				var html = `
				<div class="MDLCDivBDiv ${data.imgType}" id="MDLCDivBDiv-Peds-${cData.model}" onclick="choosePed('${cData.model}')">
					<img crossOrigin="anonymous" style="${data.style}" 
						src="${cData.image}" 
						onerror="
							this.onerror = null; 
							this.src = '${cData.image2 || 'files/menu/unknown.svg'}'; 
						">
				</div>`;
				appendHtml(document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}`), html);
				if (cData.model && cData.model === ed.myPed) {
					selectedPed = cData.model;
					document.getElementById("mainDivBottomLeftBottomDivBottomInput-PedModelInput").value=selectedPed;
					document.getElementById(`MDLCDivBDiv-Peds-${selectedPed}`).classList.add("MDLCDivBDivSelected");
				}
				return
			}
			if (data.action === "MalePeds") {
				if (ed.gender === "female" && ed.ShowAllPeds === false) {document.getElementById(data.action).style.display = "none"; return};
				var html = `
				<div class="MDLCDivBDiv ${data.imgType}" id="MDLCDivBDiv-Peds-${cData.model}" onclick="choosePed('${cData.model}')">
					<img crossOrigin="anonymous" style="${data.style}" 
						src="${cData.image}" 
						onerror="
							this.onerror = null; 
							this.src = '${cData.image2 || 'files/menu/unknown.svg'}'; 
						">
				</div>`;
				appendHtml(document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}`), html);
				if (cData.model && cData.model === ed.myPed) {
					selectedPed = cData.model;
					document.getElementById("mainDivBottomLeftBottomDivBottomInput-PedModelInput").value=selectedPed;
					document.getElementById(`MDLCDivBDiv-Peds-${selectedPed}`).classList.add("MDLCDivBDivSelected");
				}
				return
			}
			let bottomSpan = index;
			if (bottomSpan === 0) {
				bottomSpan = translations.none;
			} 
			if (data.action === "Hat" || data.action === "Glasses" || data.action === "Earrings" || data.action === "Watches" || data.action === "Bracelets") {
				var html = `
				<div class="MDLCDivBDiv ${data.imgType}" id="MDLCDivBDiv-${data.action}-${id}" onclick="changePropVariation('${data.variationNumber}', '${id}', '${data.action}')">
					<img crossOrigin="anonymous" style="${data.style}" src="${cData.image}" onerror="this.onerror=null; this.src='files/menu/unknown.svg'; this.style='width: 4vw;';">
					<div id="mainDivBottomLeftBottomDivSpanDiv">${bottomSpan}</div>
				</div>`;
				appendHtml(document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}`), html);
				if (!selectedComponentVariationData[data.action]) {
					changePropVariation(data.variationNumber, variationsData[data.action], data.action);
				}
				return
			}
			var html = `
			<div class="MDLCDivBDiv ${data.imgType}" id="MDLCDivBDiv-${data.action}-${id}" onclick="changeVariation('${data.variationNumber}', '${id}', '${data.action}')">
				<img crossOrigin="anonymous" style="${data.style}" src="${cData.image}" onerror="this.onerror=null; this.src='files/menu/unknown.svg'; this.style='width: 4vw;';">
				<div id="mainDivBottomLeftBottomDivSpanDiv">${bottomSpan}</div>
			</div>`;
			appendHtml(document.getElementById(`mainDivBottomLeftBottomDivBottom-${data.action}`), html);
		});
		if (!selectedComponentVariationData[data.action]) {
			changeVariation(data.variationNumber, variationsData[data.action], data.action);
		}
		// if (data.currentDrawableVariation !== null || data.currentDrawableVariation !== undefined) {
		// 	changeVariation(data.variationNumber, data.currentDrawableVariation, data.action, data.currentTextureDrawableVariation);
		// }
		// if (data.currentTextureDrawableVariation !== null || data.currentTextureDrawableVariation !== undefined) {
		// 	changeTextureVariation(data.variationNumber, data.currentTextureDrawableVariation, data.action);
		// }
		if (data.action === "FacialHairs" || data.action === "Eyebrows" || data.action === "Blemishes" || data.action === "Ageing" || data.action === "Complexion" || data.action === "SunDamage" || data.action === "MolesFreckles" || data.action === "ChestHair" || data.action === "BodyBlemishes" || data.action === "AddBodyBlemishes") {
			if (data.currentDrawableVariationOpacity) {
				document.getElementById(`${data.action}-OpacitySlider`).value = data.currentDrawableVariationOpacity * 100;
				let skinData = [
					{name: "FacialHairs", mainName: "FacialHairs", variationNumber: 1},
					{name: "Eyebrows", mainName: "Eyebrows", variationNumber: 2},
					{name: "Blemishes", mainName: "Blemishes", variationNumber: 0},
					{name: "Ageing", mainName: "Ageing", variationNumber: 3},
					{name: "Complexion", mainName: "Complexion", variationNumber: 6},
					{name: "SunDamage", mainName: "SunDamage", variationNumber: 7},
					{name: "MolesFreckles", mainName: "MolesFreckles", variationNumber: 9},
					{name: "ChestHair", mainName: "ChestHair", variationNumber: 10},
					{name: "BodyBlemishes", mainName: "BodyBlemishes", variationNumber: 11},
					{name: "AddBodyBlemishes", mainName: "AddBodyBlemishes", variationNumber: 12}
				];
				skinData.forEach(function(sdata, index) {
					if (!selectedComponentVariationData[sdata.mainName]) {return};
					if (!variationTexturesData[sdata.mainName]) {return};
					post({action: "changeHeadOverlay", action2: sdata.mainName, num1: Number(sdata.variationNumber), num2: selectedComponentVariationData[sdata.mainName].num, num3: variationTexturesData[sdata.mainName].currentNum, opacity: document.getElementById(`${sdata.name}-OpacitySlider`).value});
				});
				skinData.forEach(function(data, index) {
					if (!document.getElementById(`${data.name}-OpacitySlider`)) return;
					document.getElementById(`${data.name}-OpacitySlider`).addEventListener('input', function() {
						if (!selectedComponentVariationData[data.mainName]) {return};
						if (!variationTexturesData[data.mainName]) {return};
						post({action: "changeHeadOverlay", action2: data.mainName, num1: Number(data.variationNumber), num2: selectedComponentVariationData[data.mainName].num, num3: variationTexturesData[data.mainName].currentNum, opacity: document.getElementById(`${data.name}-OpacitySlider`).value});
					});
				});
			}
		}
		let skinData = [
			{name: "FacialHairs", mainName: "FacialHairs", variationNumber: 1},
			{name: "Eyebrows", mainName: "Eyebrows", variationNumber: 2},
			{name: "Blemishes", mainName: "Blemishes", variationNumber: 0},
			{name: "Ageing", mainName: "Ageing", variationNumber: 3},
			{name: "Complexion", mainName: "Complexion", variationNumber: 6},
			{name: "SunDamage", mainName: "SunDamage", variationNumber: 7},
			{name: "MolesFreckles", mainName: "MolesFreckles", variationNumber: 9},
			{name: "ChestHair", mainName: "ChestHair", variationNumber: 10},
			{name: "BodyBlemishes", mainName: "BodyBlemishes", variationNumber: 11},
			{name: "AddBodyBlemishes", mainName: "AddBodyBlemishes", variationNumber: 12}
		];
		if (data.action.includes("Color") && data.action != "EyeColor") {
			if (data.currentDrawableVariation !== null && data.currentDrawableVariation !== undefined) {
				changeVariationColor(data.action, data.currentDrawableVariation)
			}
		}
		if (data.action === "EyeColor") {
			if (data.currentDrawableVariation !== null || data.currentDrawableVariation !== undefined) {
				setPedEyeColor(data.action, data.currentDrawableVariation);
			}
		}
		if (data.action === "FaceMix") {
			document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-FaceMix").value = data.value * 10;
			post({
				action: "changeFace",
				firstShape: selectedComponentVariationData["FaceOne"].num,
				secondShape: selectedComponentVariationData["FaceTwo"].num,
				thirdShape: selectedComponentVariationData["FaceThree"].num,
				firstSkin: selectedComponentVariationData["SkinOne"].num,
				secondSkin: selectedComponentVariationData["SkinTwo"].num,
				thirdSkin: selectedComponentVariationData["SkinThree"].num,
				shapeMix: document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-FaceMix").value,
				skinMix: document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-SkinMix").value,
				thirdMix: document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-ThirdMix").value,
			});
		}
		if (data.action === "SkinMix") {
			document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-SkinMix").value = data.value * 10;
			post({
				action: "changeFace",
				firstShape: selectedComponentVariationData["FaceOne"].num,
				secondShape: selectedComponentVariationData["FaceTwo"].num,
				thirdShape: selectedComponentVariationData["FaceThree"].num,
				firstSkin: selectedComponentVariationData["SkinOne"].num,
				secondSkin: selectedComponentVariationData["SkinTwo"].num,
				thirdSkin: selectedComponentVariationData["SkinThree"].num,
				shapeMix: document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-FaceMix").value,
				skinMix: document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-SkinMix").value,
				thirdMix: document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-ThirdMix").value,
			});
		}
		if (data.action === "ThirdMix") {
			document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-ThirdMix").value = data.value * 10;
			post({
				action: "changeFace",
				firstShape: selectedComponentVariationData["FaceOne"].num,
				secondShape: selectedComponentVariationData["FaceTwo"].num,
				thirdShape: selectedComponentVariationData["FaceThree"].num,
				firstSkin: selectedComponentVariationData["SkinOne"].num,
				secondSkin: selectedComponentVariationData["SkinTwo"].num,
				thirdSkin: selectedComponentVariationData["SkinThree"].num,
				shapeMix: document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-FaceMix").value,
				skinMix: document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-SkinMix").value,
				thirdMix: document.getElementById("mainDivBottomLeftBottomDivBottomInputSlider-ThirdMix").value,
			});
		}
		if (data.action === "FaceFeatures") {
			let faceFeatData = [
				{name: "NoseWidth", variationNumber: 0},
				{name: "NosePeak", variationNumber: 1},
				{name: "NoseLength", variationNumber: 2},
				{name: "NoseBoneCurveness", variationNumber: 3},
				{name: "NoseTip", variationNumber: 4},
				{name: "NoseBoneTwist", variationNumber: 5},
				{name: "EyebrowHeight", variationNumber: 6},
				{name: "EyebrowDepth", variationNumber: 7},
				{name: "CheekBoneHeight", variationNumber: 8},
				{name: "CheekBoneWidth", variationNumber: 9},
				{name: "CheekBoneWidth2", variationNumber: 10},
				{name: "EyesSquint", variationNumber: 11},
				{name: "LipsThickness", variationNumber: 12},
				{name: "JawBoneLength", variationNumber: 13},
				{name: "JawBoneWidth", variationNumber: 14},
				{name: "ChinBoneHeight", variationNumber: 15},
				{name: "ChinBoneLength", variationNumber: 16},
				{name: "ChinBoneWidth", variationNumber: 17},
				{name: "ChinCleft", variationNumber: 18},
				{name: "NeckThickness", variationNumber: 19}
			];
			faceFeatData.forEach(function(fdata, index) {
				document.getElementById(`${fdata.name}-Slider`).value = data.data2[fdata.name] * 100;
				post({action: "changeFaceFeature", name: fdata.name, num1: fdata.variationNumber, value: document.getElementById(`${fdata.name}-Slider`).value / 100});
			});
		}
		if (data.action === "mblOpacity") {
			let makeupData = [
				{name: "Makeup", variationNumber: 4},
				{name: "Blush", variationNumber: 5},
				{name: "Lipstick", variationNumber: 8}
			];
			makeupData.forEach(function(mdata, index) {
				if (!selectedComponentVariationData[mdata.name]) {return};
				if (!variationTexturesData[mdata.name]) {return};
				document.getElementById(`${mdata.name}-OpacitySlider`).value = data[mdata.name + "Opacity"] * 100;
				post({action: "changeHeadOverlay", action2: mdata.name, num1: Number(mdata.variationNumber), num2: selectedComponentVariationData[mdata.name].num, num3: variationTexturesData[mdata.name].currentNum, opacity: document.getElementById(`${mdata.name}-OpacitySlider`).value});
			});
		}
		document.querySelectorAll('.mainDivBottomLeftBottomDivBottomInputSlider').forEach(slider => {
			const updateSliderBackground = (slider) => {
				const value = slider.value;
				const max = slider.max;
				const percentage = (value / max) * 100;
				slider.style.background = `linear-gradient(90deg, #00FFEA ${percentage}%, rgba(255, 255, 255, 0) ${percentage}%), radial-gradient(124.16% 111.18% at 50% 50%, rgba(255, 255, 255, 0.15) 0%, rgba(255, 255, 255, 0.00) 100%)`;
			};
			updateSliderBackground(slider);
			slider.addEventListener('input', function() {
				updateSliderBackground(this);
			});
		});
		document.querySelectorAll('.mainDivBottomLeftBottomDivBottomInputSlider2').forEach(slider => {
			const updateSliderBackground = (slider) => {
				const value = slider.value;
				const max = slider.max;
				const percentage = (value / max) * 100;
				slider.style.background = `linear-gradient(90deg, #00FFEA ${percentage}%, rgba(255, 255, 255, 0) ${percentage}%), radial-gradient(124.16% 111.18% at 50% 50%, rgba(255, 255, 255, 0.15) 0%, rgba(255, 255, 255, 0.00) 100%)`;
			};
			updateSliderBackground(slider);
			slider.addEventListener('input', function() {
				updateSliderBackground(this);
			});
		});
		// Face Features
		let faceFeatData = [
			{name: "NoseWidth", variationNumber: 0},
			{name: "NosePeak", variationNumber: 1},
			{name: "NoseLength", variationNumber: 2},
			{name: "NoseBoneCurveness", variationNumber: 3},
			{name: "NoseTip", variationNumber: 4},
			{name: "NoseBoneTwist", variationNumber: 5},
			{name: "EyebrowHeight", variationNumber: 6},
			{name: "EyebrowDepth", variationNumber: 7},
			{name: "CheekBoneHeight", variationNumber: 8},
			{name: "CheekBoneWidth", variationNumber: 9},
			{name: "CheekBoneWidth2", variationNumber: 10},
			{name: "EyesSquint", variationNumber: 11},
			{name: "LipsThickness", variationNumber: 12},
			{name: "JawBoneLength", variationNumber: 13},
			{name: "JawBoneWidth", variationNumber: 14},
			{name: "ChinBoneHeight", variationNumber: 15},
			{name: "ChinBoneLength", variationNumber: 16},
			{name: "ChinBoneWidth", variationNumber: 17},
			{name: "ChinCleft", variationNumber: 18},
			{name: "NeckThickness", variationNumber: 19}
		];
		faceFeatData.forEach(function(data, index) {
			document.getElementById(`${data.name}-Slider`).addEventListener('input', function() {
				post({action: "changeFaceFeature", name: data.name, num1: data.variationNumber, value: document.getElementById(`${data.name}-Slider`).value / 100});
			});
		});
	});
	document.getElementById("mainDivBottomLeftBottomDivBottomInput-PedModelInput").addEventListener("change", (event) => {
		post({action: "loadPed", model: event.target.value});
		if (document.getElementById(`MDLCDivBDiv-Peds-${event.target.value}`)) {
			choosePed(event.target.value);
		}
	});
	for (var key in translations) {
		if (translations.hasOwnProperty(key)) {
			var elements = document.getElementsByClassName(key);
			for (var i = 0; i < elements.length; i++) {
				elements[i].innerHTML = translations[key];
			}
		}
	}
}

function formatString(input) {
	let cleaned = input.replace(/\//g, '_');
	let withUnderscores = cleaned.replace(/([a-z])([A-Z])/g, '$1_$2');
	return withUnderscores.toLowerCase();
}

showClothCompareMenuState = false;
function showClothCompareMenu() {
	if (showClothCompareMenuState) {
		showClothCompareMenuState = false;
		document.getElementById("mainDivOutsideButton-ClothCompareMenu").classList.remove("mainDivOutsideButtonActive");
		document.getElementById("mainDivOutsideButton-ClothCompare1").style.display = "none";
		document.getElementById("mainDivOutsideButton-ClothCompare2").style.display = "none";
		document.getElementById("mainDivOutsideButton-ClothCompareConfirm").style.display = "none";
	} else {
		showClothCompareMenuState = true;
		document.getElementById("mainDivOutsideButton-ClothCompareMenu").classList.add("mainDivOutsideButtonActive");
		document.getElementById("mainDivOutsideButton-ClothCompare1").style.display = "flex";
		document.getElementById("mainDivOutsideButton-ClothCompare2").style.display = "flex";
		document.getElementById("mainDivOutsideButton-ClothCompareConfirm").style.display = "flex";
	}
}

function saveClothingToCompare(num) {
	if (enableCompareState) {
		document.getElementById("mainDivOutsideButton-ClothCompareConfirm").classList.remove("mainDivOutsideButtonActive");
		post({action: "stopComparingClothes"});
		savedClothData[1] = null;
		document.getElementById("mainDivOutsideButton-ClothCompare1").classList.remove("mainDivOutsideButtonActive");
		savedClothData[2] = null;
		document.getElementById("mainDivOutsideButton-ClothCompare2").classList.remove("mainDivOutsideButtonActive");
		document.getElementById("pedDiv").style.display = "flex";
		document.getElementById("pedDiv2").style.display = "none";
		document.getElementById("pedDiv3").style.display = "none";
		document.getElementById("mainDiv-Menu").style.display = "flex";
		document.getElementById("mainDivOutsideButtons").style.display = "flex";
		$("#animPosInfoDiv").css({bottom: "2%", position:'absolute', display: 'flex'}).animate({bottom: "-10%"}, 400, function() {
			$("#animPosInfoDiv").fadeOut();
		});
		choosedPed = null;
		clothMenuOpen = false;
		setTimeout(() => {
			clothMenuOpen = true;
		}, 2500);
		return;
	}
	if (savedClothData[num]) {
		savedClothData[num] = null;
		document.getElementById("mainDivOutsideButton-ClothCompare" + num).classList.remove("mainDivOutsideButtonActive");
	} else {
		for (const component in selectedComponentVariationData) {
			const texture = variationTexturesData[component]?.currentNum;
			const texture2 = variationTexturesData[component + "_2"]?.currentNum;
			if (texture !== undefined) {
				selectedComponentVariationData[component].texture = texture;
			}
			if (texture2 !== undefined) {
				selectedComponentVariationData[component].texture2 = texture2;
			}
		}
		savedClothData[num] = JSON.parse(JSON.stringify(selectedComponentVariationData));
		document.getElementById("mainDivOutsideButton-ClothCompare" + num).classList.add("mainDivOutsideButtonActive");
	}
	document.getElementById("mainDivOutsideButton-3DMenu").classList.remove("mainDivOutsideButtonActive");
	post({action: "createClone", num: num, data: savedClothData[num]});
}


function confirmCompare() {
	enableCompareState = !enableCompareState;
	if (enableCompareState) {
		document.getElementById("mainDivOutsideButton-ClothCompareConfirm").classList.add("mainDivOutsideButtonActive");
		post({action: "confirmCompare"});
		closeDialog();
		document.getElementById("pedDiv").style.display = "none";
		document.getElementById("pedDiv2").style.display = "flex";
		document.getElementById("pedDiv3").style.display = "flex";
		document.getElementById("mainDiv-Menu").style.display = "none";
		document.getElementById("mainDivOutsideButtons").style.display = "none";
		$("#animPosInfoDiv").show().css({bottom: "-10%", position:'absolute', display:'flex'}).animate({bottom: "2%"}, 500, function() {});
	} else {
		document.getElementById("mainDivOutsideButton-ClothCompareConfirm").classList.remove("mainDivOutsideButtonActive");
		post({action: "stopComparingClothes"});
		savedClothData[1] = null;
		document.getElementById("mainDivOutsideButton-ClothCompare1").classList.remove("mainDivOutsideButtonActive");
		savedClothData[2] = null;
		document.getElementById("mainDivOutsideButton-ClothCompare2").classList.remove("mainDivOutsideButtonActive");
		document.getElementById("pedDiv").style.display = "flex";
		document.getElementById("pedDiv2").style.display = "none";
		document.getElementById("pedDiv3").style.display = "none";
		document.getElementById("mainDiv-Menu").style.display = "flex";
		document.getElementById("mainDivOutsideButtons").style.display = "flex";
		$("#animPosInfoDiv").css({bottom: "2%", position:'absolute', display: 'flex'}).animate({bottom: "-10%"}, 400, function() {
			$("#animPosInfoDiv").fadeOut();
		});
		choosedPed = null;
		clothMenuOpen = false;
		setTimeout(() => {
			clothMenuOpen = true;
		}, 2500);
	}
}

enable3DMenuState = false;
function enable3DMenu() {
	if (enable3DMenuState) {
		enable3DMenuState = false;
		document.getElementById("mainDivOutsideButton-3DMenu").classList.remove("mainDivOutsideButtonActive");
		document.getElementById("mainDiv-Menu").style.transform = "none";
		document.getElementById("mainDivOutsideButtons").style.transform = "none";
		document.getElementById("mainDivOutsideButtons").style.top = "3.2%";
	} else {
		enable3DMenuState = true;
		document.getElementById("mainDivOutsideButton-3DMenu").classList.add("mainDivOutsideButtonActive");
		document.getElementById("mainDiv-Menu").style.transform = "perspective(800px) rotateY(4deg)";
		document.getElementById("mainDivOutsideButtons").style.transform = "perspective(800px) rotateY(4deg)";
		document.getElementById("mainDivOutsideButtons").style.top = "4.2%";
	}
}

function wearClothes(data) {
	let variationNumbersData = {
		["Jacket"]: {type: "normal", variationNumber: 11},
		["Pants"]: {type: "normal", variationNumber: 4},
		["FacialHairs"]: {type: "face", variationNumber: 1},
		["Hairs"]: {type: "normal", variationNumber: 2},
		["Masks"]: {type: "normal", variationNumber: 1},
		["Bag"]: {type: "normal", variationNumber: 5},
		["Hat"]: {type: "prop", variationNumber: 0},
		["Glasses"]: {type: "prop", variationNumber: 1},
		["Earrings"]: {type: "prop", variationNumber: 2},
		["Watches"]: {type: "prop", variationNumber: 6},
		["Bracelets"]: {type: "prop", variationNumber: 7},
		["Undershirt"]: {type: "normal", variationNumber: 8},
		["Arms/Gloves"]: {type: "normal", variationNumber: 3},
		["Decals"]: {type: "normal", variationNumber: 10},
		["Shoes"]: {type: "normal", variationNumber: 6},
		["Vest"]: {type: "normal", variationNumber: 9},
		["Scarfs/Necklaces"]: {type: "normal", variationNumber: 7},
		["ChestHair"]: {type: "face", variationNumber: 10},
		["Makeup"]: {type: "face", variationNumber: 4},
		["Blush"]: {type: "face", variationNumber: 5},
		["Lipstick"]: {type: "face", variationNumber: 8},
		["Eyebrows"]: {type: "face", variationNumber: 2},
	};
	Object.entries(data).forEach(([category, cData], index) => {
		if (!variationNumbersData[category]) return console.log(category + ", doesn't exist.");
		if (cData.num !== null || data.num !== undefined) {
			if (variationNumbersData[category].type === "normal" || variationNumbersData[category].type === "face") {
				changeVariation(variationNumbersData[category].variationNumber, cData.num, category, cData.texture);
			} else if (variationNumbersData[category].type === "prop") {
				changePropVariation(variationNumbersData[category].variationNumber, cData.num, category);
			}
		}
		if (cData.texture !== null || cData.texture !== undefined) {
			changeTextureVariation(variationNumbersData[category].variationNumber, cData.texture, category);
		}
	});
}