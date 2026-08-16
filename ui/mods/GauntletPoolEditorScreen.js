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
    this.mIsDirty = false;

    this.mDialogLayout = null;
    this.mTabButtonsContainer = null;
    this.mHeaders = null;
    this.mLeftColumn = null;
    this.mListContainerLayout = null;

    this.mFooterButtonBar = null;
    this.mLeaveButtonLayout = null;
    this.mUnitsBox = null;
    this.mAddUnitButtonLayout = null;
    this.mSaveButtonLayout = null;
    this.mRestoreDefaultButtonLayout = null;

    this.mColumnName = null;
    this.mColumnNum = null;
    this.mColumnDRScore = null;
    this.mColumnWeight = null;
    this.mColumnFlags = null;

    this.mPopup = null;

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

    this.mContainer = $('<div class="world-obituary-screen display-none opacity-none"/>');
    _parentDiv.append(this.mContainer);

    this.mDialogLayout = $('<div class="l-obituary-dialog-container"/>');
    this.mContainer.append(this.mDialogLayout);

    this.mDialogContainer = this.mDialogLayout.createDialog(
        'Gauntlet Pool Editor',
        '',
        '',
        true,
        'dialog-1024-768'
    );

    this.mTabButtonsContainer = $('<div class="l-tab-container"/>');
    this.mDialogContainer.findDialogTabContainer().append(
        this.mTabButtonsContainer
    );

    var content = this.mDialogContainer.findDialogContentContainer();

    this.mHeaders = $('<div class="table-header"/>');
    content.append(this.mHeaders);

    this.mColumnName = $(
        '<div class="table-header-name title title-font-big font-bold font-color-title">Name</div>'
    );
    this.mHeaders.append(this.mColumnName);

    this.mColumnNum = $(
        '<div class="table-header-unitnum title title-font-big font-bold font-color-title">Num</div>'
    );
    this.mHeaders.append(this.mColumnNum);

    this.mColumnDRScore = $(
        '<div class="table-header-drscore title title-font-big font-bold font-color-title">DR Score</div>'
    );
    this.mHeaders.append(this.mColumnDRScore);

    this.mColumnWeight = $(
        '<div class="table-header-weight title title-font-big font-bold font-color-title">Weight</div>'
    );
    this.mHeaders.append(this.mColumnWeight);

    this.mColumnFlags = $(
        '<div class="table-header-flags title title-font-big font-bold font-color-title">Flags</div>'
    );
    this.mHeaders.append(this.mColumnFlags);

    this.mLeftColumn = $('<div class="column is-left"/>');
    content.append(this.mLeftColumn);

    this.mListContainerLayout = $('<div class="l-list-container"/>');
    this.mLeftColumn.append(this.mListContainerLayout);

    this.mListContainer = this.mListContainerLayout.createList(1.0);
    this.mListScrollContainer =
        this.mListContainer.findListScrollContainer();

    /*
     * Footer
     */
    this.mFooterButtonBar = $('<div class="l-button-bar"/>');

    this.mDialogContainer
        .findDialogFooterContainer()
        .append(this.mFooterButtonBar);

    /*
     * Close
     */
    this.mLeaveButtonLayout = $('<div class="l-leave-button"/>');
    this.mFooterButtonBar.append(this.mLeaveButtonLayout);

    this.mLeaveButton = this.mLeaveButtonLayout.createTextButton(
        "Close",
        function () {
            self.notifyBackendCloseButtonPressed();
        },
        '',
        1
    );

    /*
     * Units label
     */
    this.mUnitsBox = $('<div class="units-box"/>');

    this.mUnitsBox.append(
        this.getTextDiv("", "box-subtitle", true)
    );

    this.mFooterButtonBar.append(this.mUnitsBox);

    this.mAddUnitButtonLayout =
        $('<div class="combatsim-text-button-layout"/>');

    this.mFooterButtonBar.append(this.mAddUnitButtonLayout);

    this.mAddUnitButton =
        this.mAddUnitButtonLayout.createTextButton(
            "Add Unit",
            $.proxy(function () {
                var popupContent = this.createPopup(
                    'Add Unit',
                    'combatsim-generic-popup',
                    'combatsim-generic-popup-container'
                );

                this.createAddUnitScrollContainer(
                    popupContent,
                    null
                );
            }, this),
            "combatsim-text-button",
            4
        );

    this.mSaveButtonLayout =
        $('<div class="combatsim-text-button-layout"/>');

    this.mFooterButtonBar.append(this.mSaveButtonLayout);

    this.mSaveButton =
        this.mSaveButtonLayout.createTextButton(
            "Save",
            function () {
                self.saveCurrentPool();
            },
            "combatsim-text-button",
            4
        );

    this.mRestoreDefaultButtonLayout =
        $('<div class="combatsim-text-button-layout"/>');

    this.mFooterButtonBar.append(this.mRestoreDefaultButtonLayout);

    this.mRestoreDefaultButton =
        this.mRestoreDefaultButtonLayout.createTextButton(
            "Restore Default",
            function () {
                self.restoreDefaultAll();
            },
            "combatsim-text-button",
            4
        );

    this.mIsVisible = false;

    var temp = [
        "GauntletEarly",
        "GauntletMid",
        "GauntletLate"
    ];

    this.mDropdownContainer = createDropDownMenu(
        _parentDiv,
        null,
        temp,
        null
    );
};

GauntletPoolEditorScreen.prototype.destroyDIV = function () {
    /*
     * Close any popup before destroying the screen underneath it.
     */
    if (this.mPopup !== null) {
        this.destroyPopupDialog();
        this.mPopup = null;
    }

    /*
     * Remove dropdown and its scrollbar.
     */
    if (this.mDropdownContainer !== null) {
        this.mDropdownContainer.removeChildren();
        this.mDropdownContainer.remove();
        this.mDropdownContainer = null;
    }

    /*
     * Destroy list before removing its parent.
     */
    if (this.mListScrollContainer !== null) {
        this.mListScrollContainer.empty();
        this.mListScrollContainer = null;
    }

    if (this.mListContainer !== null) {
        this.mListContainer.destroyList();
        this.mListContainer.remove();
        this.mListContainer = null;
    }

    if (this.mListContainerLayout !== null) {
        this.mListContainerLayout.remove();
        this.mListContainerLayout = null;
    }

    /*
     * Buttons.
     */
    if (this.mLeaveButton !== null) {
        this.mLeaveButton.remove();
        this.mLeaveButton = null;
    }

    if (this.mAddUnitButton !== null) {
        this.mAddUnitButton.remove();
        this.mAddUnitButton = null;
    }

    if (this.mSaveButton !== null) {
        this.mSaveButton.remove();
        this.mSaveButton = null;
    }

    if (this.mRestoreDefaultButton !== null) {
        this.mRestoreDefaultButton.remove();
        this.mRestoreDefaultButton = null;
    }

    /*
     * Button layouts.
     */
    if (this.mLeaveButtonLayout !== null) {
        this.mLeaveButtonLayout.remove();
        this.mLeaveButtonLayout = null;
    }

    if (this.mAddUnitButtonLayout !== null) {
        this.mAddUnitButtonLayout.remove();
        this.mAddUnitButtonLayout = null;
    }

    if (this.mSaveButtonLayout !== null) {
        this.mSaveButtonLayout.remove();
        this.mSaveButtonLayout = null;
    }

    if (this.mRestoreDefaultButtonLayout !== null) {
        this.mRestoreDefaultButtonLayout.remove();
        this.mRestoreDefaultButtonLayout = null;
    }

    if (this.mUnitsBox !== null) {
        this.mUnitsBox.remove();
        this.mUnitsBox = null;
    }

    if (this.mFooterButtonBar !== null) {
        this.mFooterButtonBar.remove();
        this.mFooterButtonBar = null;
    }

    /*
     * Header elements.
     */
    if (this.mColumnName !== null) {
        this.mColumnName.remove();
        this.mColumnName = null;
    }

    if (this.mColumnNum !== null) {
        this.mColumnNum.remove();
        this.mColumnNum = null;
    }

    if (this.mColumnDRScore !== null) {
        this.mColumnDRScore.remove();
        this.mColumnDRScore = null;
    }

    if (this.mColumnWeight !== null) {
        this.mColumnWeight.remove();
        this.mColumnWeight = null;
    }

    if (this.mColumnFlags !== null) {
        this.mColumnFlags.remove();
        this.mColumnFlags = null;
    }

    if (this.mHeaders !== null) {
        this.mHeaders.remove();
        this.mHeaders = null;
    }

    if (this.mTabButtonsContainer !== null) {
        this.mTabButtonsContainer.remove();
        this.mTabButtonsContainer = null;
    }

    /*
     * Remove the dialog.
     */
    if (this.mDialogContainer !== null) {
        this.mDialogContainer.empty();
        this.mDialogContainer.remove();
        this.mDialogContainer = null;
    }

    if (this.mDialogLayout !== null) {
        this.mDialogLayout.remove();
        this.mDialogLayout = null;
    }

    /*
     * Finally remove the screen root.
     */
    if (this.mContainer !== null) {
        this.mContainer.empty();
        this.mContainer.remove();
        this.mContainer = null;
    }

    this.mIsVisible = false;
    this.mSelectedPool = null;
    this.mData = null;
    this.mIsDirty = false;
};


GauntletPoolEditorScreen.prototype.markDirty = function () {
    this.mIsDirty = true;
};

GauntletPoolEditorScreen.prototype.markClean = function () {
    this.mIsDirty = false;
};

GauntletPoolEditorScreen.prototype.isDirty = function () {
    return this.mIsDirty === true;
};

GauntletPoolEditorScreen.prototype.onTableInputChanged = function () {
    this.markDirty();
};

GauntletPoolEditorScreen.prototype.addInputFieldToTable = function (
    _parent,
    _field,
    _class,
    _value
) {
    var self = this;

    var inputLayout = $('<div class="combatsim-short-input-container"/>');
    var input = $(
        '<input type="text" class="title-font-normal font-color-subtitle short-input"/>'
    );

    inputLayout.addClass(_class);
    input.val(_value);

    input.on("input", function () {
        self.onTableInputChanged();
    });


    _parent.append(inputLayout);
    inputLayout.append(input);
    _parent.data(_field, input);
};

GauntletPoolEditorScreen.prototype.addListEntry = function (_data) {
    var self = this;

    var group = $('<div class="l-row-group"/>');
    this.mListScrollContainer.append(group);

    group.data("troopData", _data)

    var result = $('<div class="l-row"/>');
    group.append(result)

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
            flagStr += ";"
        }
    }

    var flags = $('<div class ="flags text-font-normal font-color-description">' + flagStr + '</div>')
    result.append(flags);
    result.data("flags", flagStr);

    this.createRowActions(result, group);

    var coSpawn = Array.isArray(_data.CoSpawn)
        ? _data.CoSpawn
        : [];

    for (var i = 0; i < coSpawn.length; ++i) {
        this.addCoSpawnEntry(group, coSpawn[i]);
    }

    return group
}


GauntletPoolEditorScreen.prototype.addCoSpawnEntry = function (
    _group,
    _data
) {
    var self = this;
    var result = $('<div class="l-row co-spawn-row"/>');
    _group.append(result);

    var name = $(
        '<div class="name text-font-normal font-color-description">' +
        '└─ ' +
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

    var actions = $('<div class="gauntlet-row-actions"/>');
    result.append(actions);
    this.createRowActionButton(
        actions,
        Asset.BUTTON_DISMISS_CHARACTER,
        function () {
            self.markDirty();
            result.remove();
        }
    );

    return result;
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

GauntletPoolEditorScreen.prototype.collectCurrentPoolData = function () {
    var pool = {
        Name: this.mSelectedPool.Name,
        Troops: []
    };

    var rows = this.mListScrollContainer.find(".l-row-group");

    rows.each(function () {
        var group = $(this);
        var parentRow = group.children(".l-row").first();
        if (parentRow.length === 0) {
            return;
        }

        var numInput = parentRow.data("num");
        var drInput = parentRow.data("dr");
        var weightInput = parentRow.data("weight");
        var flagArray = parentRow.find(".flags").text().split(";");

        var troop = {
            Name: parentRow.find(".name").text(),
            Num: Number(numInput.val()),
            DifficultyRating: Number(drInput.val()),
            Weight: Number(weightInput.val()),
            Flags: flagArray,
            CoSpawn: []
        };

        group.children(".co-spawn-row").each(function () {
            var coSpawnRow = $(this);

            var coSpawnNumInput = coSpawnRow.data("num");

            if (coSpawnNumInput === undefined || coSpawnNumInput === null) {
                return;
            }

            troop.CoSpawn.push({
                Name: coSpawnRow
                    .find(".name")
                    .first()
                    .text()
                    .replace(/^└─\s*/, ""),
                Num: Number(coSpawnNumInput.val())
            });
        });

        pool.Troops.push(troop);
    });

    return pool;
};

GauntletPoolEditorScreen.prototype.saveCurrentPoolToBackend = function (
    _pool
) {
    if (this.mSQHandle === null) {
        console.error("Cannot save pool: screen is not connected.");
        return false;
    }
    SQ.call(this.mSQHandle, 'onSaveGauntletPool', _pool)
    return true;
};

GauntletPoolEditorScreen.prototype.saveCurrentPool = function () {
    if (this.mSelectedPool === null) {
        return false;
    }

    var pool = this.collectCurrentPoolData();

    var success = this.saveCurrentPoolToBackend(pool);

    if (success) {
        this.mSelectedPool.Troops = pool.Troops;
        this.markClean();
    }

    return success;
};

GauntletPoolEditorScreen.prototype.createUnsavedChangesPopup = function (
    _onSave,
    _onDiscard
) {
    var self = this;

    if (this.mPopup !== null) {
        console.error("A popup is already open.");
        return;
    }

    this.mPopup = this.mContainer.createPopupDialog(
        "Unsaved Changes",
        "",
        null,
        "combatsim-generic-popup gauntlet-unsaved-popup"
    );

    this.setPopupDialog(this.mPopup);

    var content = this.mPopup.addPopupDialogContent(
        $('<div class="combatsim-generic-popup-container gauntlet-unsaved-content"/>')
    );

    var message = $(
        '<div class="title-font-normal font-color-subtitle gauntlet-unsaved-message">' +
        'You have unsaved changes to this pool. What would you like to do?' +
        '</div>'
    );

    content.append(message);

    this.mPopup.addPopupDialogButton(
        "Save",
        "gauntlet-unsaved-save-button",
        function () {
            var saved = self.saveCurrentPool();

            if (!saved) {
                return;
            }

            self.destroyPopupDialog();
            self.mPopup = null;

            if (_onSave !== undefined && _onSave !== null) {
                _onSave();
            }
        },
        false
    );

    this.mPopup.addPopupDialogButton(
        "Discard",
        "gauntlet-unsaved-discard-button",
        function () {
            self.discardCurrentPoolChanges();

            self.destroyPopupDialog();
            self.mPopup = null;

            if (_onDiscard !== undefined && _onDiscard !== null) {
                _onDiscard();
            }
        },
        false
    );

    this.mPopup.addPopupDialogButton(
        "Cancel",
        "gauntlet-unsaved-cancel-button",
        function () {
            self.destroyPopupDialog();
            self.mPopup = null;
        },
        false
    );
};

GauntletPoolEditorScreen.prototype.discardCurrentPoolChanges = function () {
    if (this.mSelectedPool === null) {
        return;
    }

    //mSelectedPool represents the last saved version of this pool.
    this.mListScrollContainer.empty();

    for (var i = 0; i < this.mSelectedPool.Troops.length; ++i) {
        this.addListEntry(this.mSelectedPool.Troops[i]);
    }

    this.markClean();
};

GauntletPoolEditorScreen.prototype.confirmDiscardBefore = function (
    _callback
) {
    if (!this.isDirty()) {
        _callback();
        return;
    }

    this.createUnsavedChangesPopup(
        function () {
            _callback();
        },
        function () {
            _callback();
        }
    );
};

GauntletPoolEditorScreen.prototype.switchToPool = function (_selectedEntry) {
    this.mSelectedPool = _selectedEntry;

    this.mDialogContainer.findDialogSubTitle().text(
        "The pool " +
        _selectedEntry.Name +
        " contains " +
        _selectedEntry.Troops.length +
        " units"
    );

    this.mListScrollContainer.empty();

    for (var i = 0; i < _selectedEntry.Troops.length; ++i) {
        this.addListEntry(_selectedEntry.Troops[i]);
    }

    this.markClean();
};

GauntletPoolEditorScreen.prototype.createRowActionButton = function (
    _parent,
    _asset,
    _callback
) {
    var layout = $('<div class="action-button-layout gauntlet-row-action"/>');
    _parent.append(layout);

    var button = $('<img class="action-button"/>')
        .attr("src", Path.GFX + _asset)
        .appendTo(layout);

    button.on("click", _callback);

    return button;
};

GauntletPoolEditorScreen.prototype.createRowActions = function (
    _row,
    _group
) {
    var self = this;

    var actions = $('<div class="gauntlet-row-actions"/>');
    _row.append(actions);

    this.createRowActionButton(
        actions,
        Asset.BUTTON_DISMISS_CHARACTER,
        function () {
            self.markDirty();

            if (_group !== null && _group !== undefined) {
                _group.remove();
            } else {
                _row.remove();
            }
        }
    );

    if (_group !== null && _group !== undefined) {
        this.createRowActionButton(
            actions,
            Asset.BUTTON_TOGGLE_TREES_ENABLED,
            function () {
                var popupContent = self.createPopup(
                    'Add Unit',
                    'combatsim-generic-popup',
                    'combatsim-generic-popup-container'
                );

                self.createAddUnitScrollContainer(
                    popupContent,
                    _group
                );
            }
        );
    }

    return actions;
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
    var self = this;

    if (this.mSelectedPool === _selectedEntry) {
        return;
    }

    if (!this.isDirty()) {
        this.switchToPool(_selectedEntry);
        return;
    }

    this.createUnsavedChangesPopup(
        function () {
            self.switchToPool(_selectedEntry);
        },
        function () {
            self.switchToPool(_selectedEntry);
        }
    );

}

GauntletPoolEditorScreen.prototype.loadFromData = function (_data) {
    if (_data === undefined || _data === null) {
        return;
    }
    this.mData = _data

    if (!("Pools" in this.mData) || this.mData.Pools == null || this.mData.Pools.length <= 0) {
        this.mDialogContainer.findDialogSubTitle().text('No pool accquired!');
        this.mSelectedPool = null;
        this.markClean();
        return;
    }
    var firstPool = this.mData.Pools[0]
    var self = this;
    this.mDropdownContainer.set(
        this.mData.Pools,
        firstPool,
        function (_selectedEntry) {
            self.onChangeEntry(_selectedEntry);
        }
    );
    /*
    * setDefault() triggers the dropdown callback, so the first pool
    * becomes the current pool here.
    */
};

GauntletPoolEditorScreen.prototype.createPopup = function (_name, _popupClass, _popupDialogContentClass) {
    this.mPopup = this.mContainer.createPopupDialog(
        _name,
        "",
        null,
        _popupClass
    );

    this.setPopupDialog(this.mPopup);

    var result = this.mPopup.addPopupDialogContent(
        $('<div class="' + _popupDialogContentClass + '"/>')
    );

    this.mPopup.addPopupDialogButton(
        'OK',
        'l-ok-keybind-button',
        $.proxy(function () {
            this.destroyPopupDialog();
            this.mPopup = null;
        }, this)
    );

    return result;
}


GauntletPoolEditorScreen.prototype.getTextDiv = function (_text, _classes, _isTitle) {
    _classes = _classes || "";
    var row = $('<div class="title-font-normal font-color-subtitle combatsim-entry-label"></div>')
        .html(_text)
        .addClass(_classes)
    if (_isTitle === true)
        row.removeClass("font-color-subtitle").addClass("font-color-brother-name")
    return row;
}


GauntletPoolEditorScreen.prototype.addRow = function (_div, _classes, _divider) {
    var row = $('<div class="combatsim-row"/>');
    _div.append(row);
    if (_classes != undefined) {
        row.addClass(_classes);
    }
    if (_divider === true) {
        row.addClass("combatsim-bottom-gold-line");
    }
    return row;
}



GauntletPoolEditorScreen.prototype.createFilterBar = function (_scrollContainer) {
    var row = $('<div class="combatsim-filter-bar"/>');
    var name = this.getTextDiv("Filter")
        .appendTo(row);
    var filterLayout = $('<div class="combatsim-filter-input-container"/>')
        .appendTo(row);
    var filterInput = $('<input type="text" class="title-font-normal font-color-brother-name"/>')
        .appendTo(filterLayout)
        .on("keyup", function (_event) {
            var currentInput = $(this).val();
            var rows = _scrollContainer.find(".combatsim-row");
            rows.each(function (_idx) {
                var label = $(this).find(".combatsim-entry-label");
                if (label.length == 0) return;
                var labelText = $(label[0]).html();
                if (labelText.toLowerCase().search(currentInput.toLowerCase()) == -1) {
                    $(this).css("display", "none")
                }
                else {
                    $(this).css("display", "flex")
                }
            })
        })
    this.mActiveFilterBar = filterInput;
    return row;
}

GauntletPoolEditorScreen.prototype.focusActiveFilterBar = function () {
    if (this.mActiveFilterBar === undefined || this.mActiveFilterBar === null || this.mActiveFilterBar.length === 0)
        return;
    this.mActiveFilterBar.focus();
    this.mActiveFilterBar.select()
}

GauntletPoolEditorScreen.prototype.createAddUnitScrollContainer = function (_dialog, _coSpawnGroup) {
    var self = this;
    this.mPopupListContainer = _dialog.createList(2);
    var scrollContainer = this.mPopupListContainer.findListScrollContainer();
    _dialog.prepend(this.createFilterBar(scrollContainer));

    MSU.iterateObject(this.mData.AllUnits, $.proxy(function (_key, _unit) {
        var row = this.addRow(scrollContainer, "", true);

        var name = $('<div class="title-font-normal font-color-subtitle combatsim-entry-label">' + _unit.DisplayName + '</div>');
        row.append(name);

        var addButtonContainer = $('<div class="combatsim-text-button-layout"/>');
        var addButton = addButtonContainer.createTextButton("Add", $.proxy(function (_button) {
            var data = {
                "Name": _unit.DisplayName,
                "Num": 1,
                "Weight": 1,
                "DifficultyRating": 1
            }
            if (_coSpawnGroup === null) {
                this.addListEntry(data)
            } else {
                this.addCoSpawnEntry(_coSpawnGroup, data)
            }
            this.markDirty();
            this.focusActiveFilterBar();
        }, self), "combatsim-text-button", 4);
        // addButton.bindTooltip({ contentType: 'msu-generic', modId: CombatSimulator.ModID, elementId: "Screen.Units.Main.Add"});

        row.append(addButtonContainer);
    }, this))
    this.focusActiveFilterBar();
}



GauntletPoolEditorScreen.prototype.createRestoreDefaultPopup = function () {
    var self = this;

    if (this.mPopup !== null) {
        console.error("A popup is already open.");
        return;
    }

    this.mPopup = this.mContainer.createPopupDialog(
        "Restoring to default data",
        "",
        null,
        "combatsim-generic-popup gauntlet-unsaved-popup"
    );

    this.setPopupDialog(this.mPopup);

    var content = this.mPopup.addPopupDialogContent(
        $('<div class="combatsim-generic-popup-container gauntlet-unsaved-content"/>')
    );

    var message = $(
        '<div class="title-font-normal font-color-subtitle gauntlet-unsaved-message">' +
        'You are about to restore data to their default value. Confirm?' +
        '</div>'
    );

    content.append(message);

    this.mPopup.addPopupDialogOkButton(
        function () {
            self.notifyBackendOnRestoreDefault();

            self.destroyPopupDialog();
            self.mPopup = null;
        },
        false
    );

    this.mPopup.addPopupDialogCancelButton(
        function () {
            self.destroyPopupDialog();
            self.mPopup = null;
        },
        false
    );
}

GauntletPoolEditorScreen.prototype.restoreDefaultAll = function () {
    this.createRestoreDefaultPopup();
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

GauntletPoolEditorScreen.prototype.notifyBackendOnRestoreDefault = function () {
    if (this.mSQHandle !== null) {
        SQ.call(this.mSQHandle, 'onRestoreDefault');
    }
}

GauntletPoolEditorScreen.prototype.notifyBackendCloseButtonPressed = function (
    _buttonID
) {
    var self = this;

    if (!this.isDirty()) {
        if (this.mSQHandle !== null) {
            SQ.call(this.mSQHandle, "onClose", _buttonID);
        }

        return;
    }

    this.createUnsavedChangesPopup(
        function () {
            if (self.mSQHandle !== null) {
                SQ.call(self.mSQHandle, "onClose", _buttonID);
            }
        },
        function () {
            if (self.mSQHandle !== null) {
                SQ.call(self.mSQHandle, "onClose", _buttonID);
            }
        }
    );
};


registerScreen("GauntletPoolEditorScreen", new GauntletPoolEditorScreen());