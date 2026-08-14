"use strict";
var ModGauntletEvents = {
    ModID: "mod_gauntlet_events"
}

var GauntletPoolEditorScreen = function (_parent) {
    MSUUIScreen.call(this);
    this.mModID = "mod_gauntlet_events"
    this.mID = "GauntletPoolEditorScreen";
    // this.mSQHandle = null;

    // generic containers
    this.mContainer = null;
    this.mDialogContainer = null;
    this.mDropdownContainer = null;
    this.mListContainer = null;
    this.mListScrollContainer = null;
    this.mAddUnitButton = null;
    this.mActiveFilterBar = null;
    this.mPopupListContainer = null;

    // buttons
    this.mLeaveButton = null;

    // generics
    this.mIsVisible = false;

    // selected entry
    this.mSelectedPool = null;
    this.mData = null;
};

GauntletPoolEditorScreen.prototype = Object.create(MSUUIScreen.prototype)
Object.defineProperty(GauntletPoolEditorScreen.prototype, 'constructor', {
    value: GauntletPoolEditorScreen,
    enumerable: false,
    writable: true
});

GauntletPoolEditorScreen.prototype.isConnected = function () {
    return this.mSQHandle !== null;
};
GauntletPoolEditorScreen.prototype.onConnection = function (_handle) {
    this.mSQHandle = _handle;
    this.register($('.root-screen'));
};
GauntletPoolEditorScreen.prototype.onDisconnection = function () {
    this.mSQHandle = null; this.unregister();
};
GauntletPoolEditorScreen.prototype.getModule = function (_name) {
    switch (_name) {
        default: return null;
    }
};
GauntletPoolEditorScreen.prototype.getModules = function () {
    return [];
};

GauntletPoolEditorScreen.prototype.createDIV = function (_parentDiv) {
    var self = this;

    // create: containers (init hidden!)
    this.mContainer = $('<div class="world-obituary-screen display-none opacity-none"/>');
    _parentDiv.append(this.mContainer);

    // create: containers (init hidden!)
    var dialogLayout = $('<div class="l-obituary-dialog-container"/>');
    this.mContainer.append(dialogLayout);
    this.mDialogContainer = dialogLayout.createDialog('Gauntlet Pool Editor', '', '', true, 'dialog-1024-768');

    // create tabs
    var tabButtonsContainer = $('<div class="l-tab-container"/>');
    this.mDialogContainer.findDialogTabContainer().append(tabButtonsContainer);

    // create content
    var content = this.mDialogContainer.findDialogContentContainer();

    // column headers
    var headers = $('<div class="table-header"/>');
    content.append(headers);

    this.mColumnName = $('<div class="table-header-name title title-font-big font-bold font-color-title">Name</div>');
    headers.append(this.mColumnName);

    this.mColumnNum = $('<div class="table-header-unitnum title title-font-big font-bold font-color-title">Num</div>');
    headers.append(this.mColumnNum);

    this.mColumnDRScore = $('<div class="table-header-drscore title title-font-big font-bold font-color-title">DR Score</div>');
    headers.append(this.mColumnDRScore);

    this.mColumnWeight = $('<div class="table-header-weight title title-font-big font-bold font-color-title">Weight</div>');
    headers.append(this.mColumnWeight);

    this.mColumnFlags = $('<div class="table-header-flags title title-font-big font-bold font-color-title">Flags</div>');
    headers.append(this.mColumnFlags);

    // left column
    var column = $('<div class="column is-left"/>');
    content.append(column);
    var listContainerLayout = $('<div class="l-list-container"/>');
    column.append(listContainerLayout);
    this.mListContainer = listContainerLayout.createList(1.0/*8.85*/);
    this.mListScrollContainer = this.mListContainer.findListScrollContainer();

    // create footer button bar
    var footerButtonBar = $('<div class="l-button-bar"/>');
    this.mDialogContainer.findDialogFooterContainer().append(footerButtonBar);

    // create: buttons
    var layout = $('<div class="l-leave-button"/>');
    footerButtonBar.append(layout);
    this.mLeaveButton = layout.createTextButton("Close", function () {
        self.notifyBackendCloseButtonPressed();
    }, '', 1);

    // create a second button
    var unitsBox = $('<div class="units-box"/>')
        .append(this.getTextDiv("Units", "box-subtitle", true))
    footerButtonBar.append(unitsBox)

    var layoutAddUnit = $('<div class="combatsim-text-button-layout"/>');
    footerButtonBar.append(layoutAddUnit);
    this.mAddUnitButton = layoutAddUnit.createTextButton("Add Unit", $.proxy(function (_div) {
        this.createAddUnitScrollContainer(this.createPopup('Add Unit', 'combatsim-generic-popup', 'combatsim-generic-popup-container'), this.mListScrollContainer);
    }, this), "combatsim-text-button", 4);

    this.mIsVisible = false;

    var temp = ["GauntletEarly", "GauntletMid", "GauntletLate"]
    this.mDropdownContainer = createDropDownMenu(_parentDiv, null, temp, null)
};

GauntletPoolEditorScreen.prototype.destroyDIV = function () {
    //this.mAssets.destroyDIV();

    this.mListScrollContainer.empty();
    this.mListScrollContainer = null;
    this.mListContainer.destroyList();
    this.mListContainer.remove();
    this.mListContainer = null;

    this.mLeaveButton.remove();
    this.mLeaveButton = null;

    this.mDialogContainer.empty();
    this.mDialogContainer.remove();
    this.mDialogContainer = null;

    this.mContainer.empty();
    this.mContainer.remove();
    this.mContainer = null;
};

GauntletPoolEditorScreen.prototype.addInputFieldToTable = function (
    _parent,
    _field,
    _class,
    _value
) {
    var inputLayout = $('<div class="combatsim-short-input-container"/>');
    var input = $(
        '<input type="text" class="title-font-normal font-color-subtitle short-input"/>'
    );

    inputLayout.addClass(_class);
    input.val(_value);

    _parent.append(inputLayout);
    inputLayout.append(input);
    _parent.data(_field, input);
};

GauntletPoolEditorScreen.prototype.addListEntry = function (_data) {
    var result = $('<div class="l-row"/>');
    this.mListScrollContainer.append(result);

    var name = $(
        '<div class="name text-font-normal font-color-description">' +
        _data.Name +
        '</div>'
    );

    result.append(name);

    this.addInputFieldToTable(
        result,
        "num",
        "unitnum",
        _data.Num
    );

    this.addInputFieldToTable(
        result,
        "dr",
        "drscore",
        _data.DifficultyRating
    );

    this.addInputFieldToTable(
        result,
        "weight",
        "weight",
        _data.Weight
    );

    var flagStr = ""
    for (var i = 0; i < _data.Flags.length; i++) {
        flagStr += _data.Flags[i]
        if (i < _data.Flags.length - 1) {
            flagStr += ", "
        }
    }

    var flags = $('<div class ="flags text-font-normal font-color-description">' + flagStr + '</div>')
    result.append(flags)

};

GauntletPoolEditorScreen.prototype.bindTooltips = function () {
    this.mColumnName.bindTooltip({ contentType: 'ui-element', elementId: TooltipIdentifier.WorldScreen.Obituary.ColumnName });
    this.mColumnDRScore.bindTooltip({ contentType: 'ui-element', elementId: TooltipIdentifier.WorldScreen.Obituary.ColumnTime });
    this.mColumnNum.bindTooltip({ contentType: 'ui-element', elementId: TooltipIdentifier.WorldScreen.Obituary.ColumnBattles });
    this.mColumnWeight.bindTooltip({ contentType: 'ui-element', elementId: TooltipIdentifier.WorldScreen.Obituary.ColumnKills });
};

GauntletPoolEditorScreen.prototype.unbindTooltips = function () {
    this.mColumnName.unbindTooltip();
    this.mColumnDRScore.unbindTooltip();
    this.mColumnNum.unbindTooltip();
    this.mColumnWeight.unbindTooltip();
};


GauntletPoolEditorScreen.prototype.create = function (_parentDiv) {
    this.createDIV(_parentDiv);
    this.bindTooltips();
};

GauntletPoolEditorScreen.prototype.destroy = function () {
    this.unbindTooltips();
    this.destroyDIV();
};


GauntletPoolEditorScreen.prototype.register = function (_parentDiv) {
    console.log('GauntletPoolEditorScreen::REGISTER');

    if (this.mContainer !== null) {
        console.error('ERROR: Failed to register Relations Screen. Reason: Already initialized.');
        return;
    }

    if (_parentDiv !== null && typeof (_parentDiv) == 'object') {
        this.create(_parentDiv);
    }
};

GauntletPoolEditorScreen.prototype.unregister = function () {
    console.log('GauntletPoolEditorScreen::UNREGISTER');

    if (this.mContainer === null) {
        console.error('ERROR: Failed to unregister Relations Screen. Reason: Not initialized.');
        return;
    }

    this.destroy();
};

GauntletPoolEditorScreen.prototype.isRegistered = function () {
    if (this.mContainer !== null) {
        return this.mContainer.parent().length !== 0;
    }

    return false;
};


GauntletPoolEditorScreen.prototype.show = function (_data) {
    this.loadFromData(_data);

    if (!this.mIsVisible) {
        var self = this;

        var withAnimation = true;//(_data !== undefined && _data['withSlideAnimation'] !== null) ? _data['withSlideAnimation'] : true;
        if (withAnimation === true) {
            var offset = -(this.mContainer.parent().width() + this.mContainer.width());
            this.mContainer.css({ 'left': offset });
            this.mContainer.velocity("finish", true).velocity({ opacity: 1, left: '0', right: '0' }, {
                duration: Constants.SCREEN_SLIDE_IN_OUT_DELAY,
                easing: 'swing',
                begin: function () {
                    $(this).removeClass('display-none').addClass('display-block');
                    self.notifyBackendOnAnimating();
                },
                complete: function () {
                    self.mIsVisible = true;
                    self.notifyBackendOnShown();
                }
            });
        }
        else {
            this.mContainer.css({ opacity: 0 });
            this.mContainer.velocity("finish", true).velocity({ opacity: 1 }, {
                duration: Constants.SCREEN_FADE_IN_OUT_DELAY,
                easing: 'swing',
                begin: function () {
                    $(this).removeClass('display-none').addClass('display-block');
                    self.notifyBackendOnAnimating();
                },
                complete: function () {
                    self.mIsVisible = true;
                    self.notifyBackendOnShown();
                }
            });
        }
    }
};

GauntletPoolEditorScreen.prototype.hide = function (_withSlideAnimation) {
    var self = this;

    var withAnimation = true;//(_withSlideAnimation !== undefined && _withSlideAnimation !== null) ? _withSlideAnimation : true;
    if (withAnimation === true) {
        var offset = -(this.mContainer.parent().width() + this.mContainer.width());
        this.mContainer.velocity("finish", true).velocity({ opacity: 0, left: offset },
            {
                duration: Constants.SCREEN_SLIDE_IN_OUT_DELAY,
                easing: 'swing',
                begin: function () {
                    $(this).removeClass('is-center');
                    self.notifyBackendOnAnimating();
                },
                complete: function () {
                    self.mIsVisible = false;
                    self.mListScrollContainer.empty();
                    $(this).removeClass('display-block').addClass('display-none');
                    self.notifyBackendOnHidden();
                }
            });
    }
    else {
        this.mContainer.velocity("finish", true).velocity({ opacity: 0 },
            {
                duration: Constants.SCREEN_SLIDE_IN_OUT_DELAY,
                easing: 'swing',
                begin: function () {
                    $(this).removeClass('is-center');
                    self.notifyBackendOnAnimating();
                },
                complete: function () {
                    self.mIsVisible = false;
                    self.mListScrollContainer.empty();
                    $(this).removeClass('display-block').addClass('display-none');
                    self.notifyBackendOnHidden();
                }
            });
    }
};

var widthTester = $('<div id="WidthTester"/>')
    .css({ 'position': 'absolute', 'float': 'left', 'white-space': 'nowrap', 'visibility': 'hidden' })
    .addClass("text-font-normal")
    .appendTo($('body'))

var getWidthOfDropdownChild = function (_text) {
    widthTester.text(_text);
    return widthTester.width();
}

var createDropDownMenu = function (_parentDiv, _classes, _childrenArray, _default, _onChangeCallback) {
    // NOTE: you need to pass the _parentDiv that the dropdown gets attached to
    // This is due do aciScrollBar
    // The _parentDiv needs to be attached to the DOM!!!
    // The maximum height of the element container is 20rem, but this can be changed via setting data("maxHeight") on the result
    var result = $('<div class="dropdown"/>')
        .addClass(_classes || "")
        .data("activeElement", null)
        .append($('<div class="dropdown-text text-font-normal font-color-label"/>'))

    var container = $('<div class="dropdown-container"/>')
        .append($('<div class="dropdown-container-scroll"/>'))
        .appendTo(result)

    result.addChildren = function (_children) {
        var innerContainer = this.find(".dropdown-container-scroll");
        var outerContainer = this.find(".dropdown-container");
        var width = 175;
        $.each(_children, function (_idx, _element) {
            var child = $('<div class="dropdown-child text-font-normal font-color-label"/>')
                .data("Element", _element)
                .appendTo(innerContainer)

            if (typeof _element == "object") {
                if (_element.Name === undefined)
                    console.error("Passed an object as dropdown member but it does not have a .Name member to use as label!")
                child.text(_element.Name)
            }
            else child.text(_element)

            child.on("click", function (_event) {
                var dropDown = $(this).closest(".dropdown");
                dropDown.find(".dropdown-child").removeClass("is-selected");
                $(this).addClass("is-selected");
                dropDown.find(".dropdown-text").text($(this).text());
                dropDown.data("activeElement", $(this).data("Element"));
                if (dropDown.data("callback") !== undefined && dropDown.data("callback") !== null) {
                    dropDown.data("callback")($(this).data("Element"));
                }
                return false;
            })
            width = Math.max(width, getWidthOfDropdownChild(_element.Name))
        })
        var newheight = Math.min(this.data("maxHeight") || 20, innerContainer.children().length * 3) + "rem";
        outerContainer.css("height", newheight);
        this.width(width);
    }

    result.setDefault = function (_default) {
        this.find(".dropdown-child").each(function () {
            if ($(this).data("Element") == _default) {
                $(this).click();
            }
        })
    }

    result.setCallback = function (_function) {
        this.data("callback", _function);
    }

    result.removeChildren = function () {
        this.find(".dropdown-container-scroll").empty();
    }

    result.get = function () {
        return this.data("activeElement");
    }

    result.set = function (_children, _default, _callback) {
        this.attr('disabled', false);
        this.removeChildren();
        if (_callback !== undefined && _callback !== null)
            this.setCallback(_callback)

        if (_children !== undefined && _children !== null)
            this.addChildren(_children)

        if (_default !== undefined && _default !== null)
            this.setDefault(_default)

        if ((_children === undefined || _children.length == 0) || this.get() === undefined) {
            this.attr('disabled', true);
        }
    }

    result.set(_childrenArray, _default, _onChangeCallback);

    // These must be last!
    _parentDiv.append(result);
    container.aciScrollBar({
        delta: 1,
        lineDelay: 0,
        lineTimer: 0,
        pageDelay: 0,
        pageTimer: 0,
        bindKeyboard: false,
        resizable: false,
        smoothScroll: false
    });

    return result;
}


GauntletPoolEditorScreen.prototype.isVisible = function () {
    return this.mIsVisible;
};


GauntletPoolEditorScreen.prototype.onChangeEntry = function (_selectedEntry) {
    // this.mSelectedPool = _selectedEntry
    this.mDialogContainer.findDialogSubTitle().text('The pool ' + _selectedEntry.Name + ' contains ' + _selectedEntry.Troops.length + ' units');

    this.mListScrollContainer.empty()

    for (var i = 0; i < _selectedEntry.Troops.length; ++i) {
        this.addListEntry(_selectedEntry.Troops[i]);
    }

}

GauntletPoolEditorScreen.prototype.loadFromData = function (_data) {
    if (_data === undefined || _data === null) {
        return;
    }
    this.mData = _data

    if (!("Pools" in this.mData) || this.mData.Pools == null || this.mData.Pools.length <= 0) {
        this.mDialogContainer.findDialogSubTitle().text('No pool accquired!');
    }
    else {
        var firstPool = this.mData.Pools[0]
        var self = this;
        this.mDropdownContainer.set(
            this.mData.Pools,
            firstPool,
            function (_selectedEntry) {
                self.onChangeEntry(_selectedEntry);
            }
        );
    }

    // MSU.printData(_data, 10, 100)
    // for (var i = 0; i < _data.Pool.Data.length; ++i) {
    //     this.addListEntry(_data.Pool.Data[i]);
    // }
};

GauntletPoolEditorScreen.prototype.createPopup = function (_name, _popupClass, _popupDialogContentClass) {
    var self = this;
    this.popup = this.mContainer.createPopupDialog(_name, "", null, _popupClass);
    this.setPopupDialog(this.popup);
    var result = this.popup.addPopupDialogContent($('<div class="' + _popupDialogContentClass + '"/>'));
    this.popup.addPopupDialogButton('OK', 'l-ok-keybind-button', $.proxy(function (_dialog) {
        this.destroyPopupDialog();
    }, this));
    return result;
}


GauntletPoolEditorScreen.prototype.getTextDiv = function(_text, _classes, _isTitle)
{
    _classes = _classes || "";
    var row = $('<div class="title-font-normal font-color-subtitle combatsim-entry-label"></div>')
        .html(_text)
        .addClass(_classes)
    if (_isTitle === true)
        row.removeClass("font-color-subtitle").addClass("font-color-brother-name")
    return row;
}


GauntletPoolEditorScreen.prototype.addRow = function(_div, _classes, _divider)
{
    var row = $('<div class="combatsim-row"/>');
    _div.append(row);
    if (_classes != undefined)
    {
        row.addClass(_classes);
    }
    if(_divider === true)
    {
        row.addClass("combatsim-bottom-gold-line");
    }
    return row;
}



GauntletPoolEditorScreen.prototype.createFilterBar = function(_scrollContainer)
{
    var row = $('<div class="combatsim-filter-bar"/>');
    var name = this.getTextDiv("Filter")
        .appendTo(row);
    var filterLayout = $('<div class="combatsim-filter-input-container"/>')
        .appendTo(row);
    var filterInput = $('<input type="text" class="title-font-normal font-color-brother-name"/>')
        .appendTo(filterLayout)
        .on("keyup", function(_event){
            var currentInput = $(this).val();
            var rows = _scrollContainer.find(".combatsim-row");
            rows.each(function(_idx){
                var label = $(this).find(".combatsim-entry-label");
                if (label.length == 0) return;
                var labelText = $(label[0]).html();
                if (labelText.toLowerCase().search(currentInput.toLowerCase()) == -1)
                {
                    $(this).css("display", "none")
                }
                else
                {
                    $(this).css("display", "flex")
                }
            })
        })
    this.mActiveFilterBar = filterInput;
    return row;
}

GauntletPoolEditorScreen.prototype.focusActiveFilterBar = function()
{
    if (this.mActiveFilterBar === undefined || this.mActiveFilterBar === null || this.mActiveFilterBar.length === 0)
        return;
    this.mActiveFilterBar.focus();
    this.mActiveFilterBar.select()
}

GauntletPoolEditorScreen.prototype.createAddUnitScrollContainer = function(_dialog, _side)
{
    var self = this;
    this.mPopupListContainer = _dialog.createList(2);
    var scrollContainer = this.mPopupListContainer.findListScrollContainer();
    _dialog.prepend(this.createFilterBar(scrollContainer));

    MSU.iterateObject(this.mData.AllUnits, $.proxy(function(_key, _unit){
        var row = this.addRow(scrollContainer, "", true);

        var name = $('<div class="title-font-normal font-color-subtitle combatsim-entry-label">' + _unit.DisplayName +  '</div>');
        row.append(name);

        var addButtonContainer = $('<div class="combatsim-text-button-layout"/>');
        var addButton = addButtonContainer.createTextButton("Add", $.proxy(function (_button) {
            var data = {
                "Name": _unit.DisplayName,
                "Num": 1,
                "Weight": 1,
                "DifficultyRating": 1
            }
            this.addListEntry(data) //this.addUnitToBox(_unit, _side, _key);
            this.focusActiveFilterBar();
        }, self), "combatsim-text-button", 4);
        // addButton.bindTooltip({ contentType: 'msu-generic', modId: CombatSimulator.ModID, elementId: "Screen.Units.Main.Add"});

        row.append(addButtonContainer);
    }, this))
    this.focusActiveFilterBar();
}

GauntletPoolEditorScreen.prototype.notifyBackendOnConnected = function () {
    if (this.mSQHandle !== null) {
        SQ.call(this.mSQHandle, 'onScreenConnected');
    }
};

GauntletPoolEditorScreen.prototype.notifyBackendOnDisconnected = function () {
    if (this.mSQHandle !== null) {
        SQ.call(this.mSQHandle, 'onScreenDisconnected');
    }
};

GauntletPoolEditorScreen.prototype.notifyBackendOnShown = function () {
    if (this.mSQHandle !== null) {
        SQ.call(this.mSQHandle, 'onScreenShown');
    }
};

GauntletPoolEditorScreen.prototype.notifyBackendOnHidden = function () {
    if (this.mSQHandle !== null) {
        SQ.call(this.mSQHandle, 'onScreenHidden');
    }
};

GauntletPoolEditorScreen.prototype.notifyBackendOnAnimating = function () {
    if (this.mSQHandle !== null) {
        SQ.call(this.mSQHandle, 'onScreenAnimating');
    }
};

GauntletPoolEditorScreen.prototype.notifyBackendCloseButtonPressed = function (_buttonID) {
    if (this.mSQHandle !== null) {
        SQ.call(this.mSQHandle, 'onClose', _buttonID);
    }
};

registerScreen("GauntletPoolEditorScreen", new GauntletPoolEditorScreen());