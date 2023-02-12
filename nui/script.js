// MENU UI
let menuParams = [];

const openMenu = (data = null) => {
    let html = ""
    data.forEach((item, index) => {
        let title = item.title;
        let description = item.description;
        let isMainTitle = item.isMainTitle;
        html += renderMenus(title, description, index, isMainTitle);
        menuParams[index] = item;
    });

    $("#menus").html(html);
};

const renderMenus = (title, description = null, id, isMainTitle) => {
    if (description) {
        return `
            <div class="${isMainTitle ? "menutitle" : "menu"}" data-btn-id="${id}">
                <div class="header">${title}</div>
                <div class="text">${description}</div>
            </div>
        `;
    } else {
        return `
            <div class="${isMainTitle ? "menutitle" : "menu"}" data-btn-id="${id}">
                <div class="header">${title}</div>
            </div>
        `;
    }
};

const closeMenu = () => {
    $("#menus").html(" ");
    menuParams = [];
};

const postData = (id) => {
    if (!menuParams[id]) return console.log("error occured");

    $.post(
        `https://${GetParentResourceName()}/menuPressed`,
        JSON.stringify(menuParams[id])
    );
    return closeMenu();
};

const cancelMenu = () => {
    $.post(`https://${GetParentResourceName()}/closeMenu`);
    return closeMenu();
};

$(document).click(function (event) {
    let target = $(event.target);
    if (target.closest(".menu").length && $(".menu").is(":visible")) {
        let btnId = $(event.target).closest(".menu").data("btn-id");
        postData(btnId);
    }
});

// TEXT UI
const openTextUI = (btn, msg) => {
    $(".textui-circle").text(""+btn+"");
	$(".textui-text").text(""+msg+"");
    $(".textui-container").fadeIn(100);
}

const closeTextUI = () => {
    $(".textui-circle").text(" ");
    $(".textui-text").text(" ");
    $(".textui-container").fadeOut(100);
}

window.addEventListener("message", (event) => {
    const data = event.data;
    const menus = data.data;
    const action = data.action;
    switch (action) {
        case "OPEN_MENU":
            return openMenu(menus);
        case "CLOSE_MENU":
            return closeMenu();
        case "OPEN_TEXTUI":
            return openTextUI(data.button, data.text);
        case "CLOSE_TEXTUI":
            return closeTextUI();
        default:
            return;
    }
});

document.onkeyup = function (event) {
    const charCode = event.key;
    if (charCode == "Escape") {
        cancelMenu();
    }
};