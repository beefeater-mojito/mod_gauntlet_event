"use strict";
var ModGauntletEvents = {
    ModID: "mod_gauntlet_events",
    AvailableFlags: {
        IsRange: {
            Icon: Asset.ICON_RANGE_SKILL,
            Tooltip: "Range"
        },
        IsSquishyMelee: {
            Icon: Asset.ICON_DAMAGE_RECEIVED,
            Tooltip: "SquishyMelee"
        },
        IsCrowdControl: {
            Icon: Asset.ICON_CENTER,
            Tooltip: "CrowdControl"
        },
        IsBoss: {
            Icon: Asset.ICON_CHANCE_TO_HIT_HEAD,
            Tooltip: "Boss"
        }
    },
    UnitProperties: { // TODO: map hard-coded value to this
        Name: {
            Id: "name",
            ClassName: "name",
            Type: "String"
        },
        Num: {
            Id: "num",
            ClassName: "unitnum",
            Type: "Integer"
        },
        DifficultyRating: {
            Id: "dr",
            ClassName: "drscore",
            Type: "Number"
        },
        Weight: {
            Id: "weight",
            ClassName: "weight",
            Type: "Number"
        }
    },
    CoSpawnProperties: {
        Name: {
            Id: "name",
            ClassName: "name",
            Type: "String"
        },
        Num: {
            Id: "num",
            ClassName: "unitnum",
            Type: "Integer"
        }
    },
    CombatSetting: {
        DifficultyScore: {
            Id: "diffScore",
            ClassName: "",
            Type: "Number"
        },
        Days: {
            Id: "days",
            ClassName: "",
            Type: "Integer"
        }
    },
    GauntletPoolOrder: [
        "GauntletEarly",
        "GauntletMid",
        "GauntletLate",
        "GauntletChampion",
        "GauntletMiniBoss",
        "GauntletBoss",
        "GauntletPreset"
    ],
    FilterState: {
        // nofilter -> include -> exclude -> nofilter
        NoFilter: {
            Id: "nofilter",
            Icon: 'ui/icons/gauntlet_editor_nofilter.png',
            doStateTransition: function (_flagKey, _includeFilters, _excludeFilters) {
                delete _excludeFilters[_flagKey];
            }
        },
        Include: {
            Id: "include",
            Icon: 'ui/icons/gauntlet_editor_include.png',
            doStateTransition: function (_flagKey, _includeFilters, _excludeFilters) {
                _includeFilters[_flagKey] = ModGauntletEvents.AvailableFlags[_flagKey];
            }
        },
        Exclude: {
            Id: "exclude",
            Icon: 'ui/icons/gauntlet_editor_exclude.png',
            doStateTransition: function (_flagKey, _includeFilters, _excludeFilters) {
                delete _includeFilters[_flagKey];
                _excludeFilters[_flagKey] = ModGauntletEvents.AvailableFlags[_flagKey];
            }
        }
    },
    DisplayHiddenClass: "hideProperty"
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
    this.mSettingIDCounters = null;

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
    this.mStartCombatButtonLayout = null;
    this.mRestoreDefaultButtonLayout = null;

    this.mColumnName = null;
    this.mColumnNum = null;
    this.mColumnDRScore = null;
    this.mColumnWeight = null;
    this.mColumnFlags = null;

    this.mPopup = null;
    this.mIconRow = null;

    this.mLastInvalidInput = null;
    this.mIncludeFilters = null;
    this.mExcludeFilters = null;
    this.mFlagFilterButtons = null;
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

    this.mContainer = $('<div class="gauntlet-editor-screen display-none opacity-none"/>');
    _parentDiv.append(this.mContainer);

    this.mDialogLayout = $('<div class="l-gauntlet-dialog-container"/>');
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

    var dropdownLayout = $('<div class="gauntlet-dropdown-menu-layout"/>');
    this.mContainer.append(dropdownLayout);

    var temp = [
        "GauntletEarly",
        "GauntletMid",
        "GauntletLate"
    ];

    this.mDropdownContainer = createDropDownMenu(
        dropdownLayout,
        null,
        temp,
        null
    );

    var content = this.mDialogContainer.findDialogContentContainer();
    /*Headers */
    this.mHeaders = $('<div class="table-header"/>');
    content.append(this.mHeaders);

    this.mColumnName = $(
        '<div class="table-header-name title title-font-big font-bold font-color-title">Name</div>'
    );
    this.mColumnName.bindTooltip({ contentType: 'msu-generic', modId: ModGauntletEvents.ModID, elementId: "GauntletEditorScreen.Units.Name" })
    this.mHeaders.append(this.mColumnName);

    this.mColumnNum = $(
        '<div class="table-header-unitnum title title-font-big font-bold font-color-title">Num</div>'
    );
    this.mColumnNum.bindTooltip({ contentType: 'msu-generic', modId: ModGauntletEvents.ModID, elementId: "GauntletEditorScreen.Units.Num" })
    this.mHeaders.append(this.mColumnNum);

    this.mColumnDRScore = $(
        '<div class="table-header-drscore title title-font-big font-bold font-color-title">DR Score</div>'
    );
    this.mColumnDRScore.bindTooltip({ contentType: 'msu-generic', modId: ModGauntletEvents.ModID, elementId: "GauntletEditorScreen.Units.DifficultyRating" })
    this.mHeaders.append(this.mColumnDRScore);

    this.mColumnWeight = $(
        '<div class="table-header-weight title title-font-big font-bold font-color-title">Weight</div>'
    );
    this.mColumnWeight.bindTooltip({ contentType: 'msu-generic', modId: ModGauntletEvents.ModID, elementId: "GauntletEditorScreen.Units.Weight" })
    this.mHeaders.append(this.mColumnWeight);

    this.mColumnFlags = $(
        '<div class="table-header-flags title title-font-big font-bold font-color-title">Flags</div>'
    );
    this.mColumnFlags.bindTooltip({ contentType: 'msu-generic', modId: ModGauntletEvents.ModID, elementId: "GauntletEditorScreen.Units.Flags" });
    this.mHeaders.append(this.mColumnFlags);

    this.mColumnButtons = $(
        '<div class="gauntlet-topbar-buttons"/>'
    )
    this.mHeaders.append(this.mColumnButtons)
    /*Headers buttons*/
    this.createOverlayImageButton(
        this.mColumnButtons,
        Asset.ICON_CONTRACT_SCROLL,
        function () {
            self.discardCurrentPoolChanges();
        },
        "topbar-button-layout",
        6,
        "GauntletEditorScreen.TopbarButton.RevertChange"
    )
    this.createOverlayImageButton(
        this.mColumnButtons,
        Asset.ICON_CAMERALOCK,
        function () {
            self.restoreDefaultThis();
        },
        "topbar-button-layout",
        6,
        "GauntletEditorScreen.TopbarButton.RestoreThis"
    )
    this.createOverlayImageButton(
        this.mColumnButtons,
        Asset.ICON_UNKNOWN_TRAITS,
        function () {
            self.createHelpPopup();
        },
        "topbar-button-layout",
        6,
        "GauntletEditorScreen.TopbarButton.ViewHelp"
    )
    this.createOverlayImageButton(
        this.mColumnButtons,
        'ui/icons/gauntlet_editor_copy_button.png',
        function () {
            var success = self.copyCurrentPoolDataToClipboard();
            if (!success) {
                self.createFailedToCopyPopup();
            }
        },
        "topbar-button-layout",
        6,
        "GauntletEditorScreen.TopbarButton.CopyPool"
    )
    this.createOverlayImageButton(
        this.mColumnButtons,
        'ui/icons/gauntlet_editor_clipboard_notes_button.png',
        function () {
            self.pastePoolDataFromClipboard()
        },
        "topbar-button-layout",
        6,
        "GauntletEditorScreen.TopbarButton.PastePool"
    )

    /* Dialog */
    this.mLeftColumn = $('<div class="column is-left"/>');
    content.append(this.mLeftColumn);

    this.mIconRow = $('<div class="l-row-group"/>');
    content.append(this.mIconRow)

    this.mIncludeFilters = {};
    this.mExcludeFilters = {};
    this.mFlagFilterButtons = {};
    this.addFlagsIconRow(this.mIconRow);

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
    this.mLeaveButton.bindTooltip({ contentType: 'msu-generic', modId: ModGauntletEvents.ModID, elementId: "GauntletEditorScreen.FootbarButton.Close" })
    // Add unit
    this.mAddUnitButtonLayout =
        $('<div class="gauntlet-text-button-layout"/>');
    this.mFooterButtonBar.append(this.mAddUnitButtonLayout);
    this.mAddUnitButton =
        this.mAddUnitButtonLayout.createTextButton(
            "Add Unit",
            $.proxy(function () {
                var popupContent = this.createPopup(
                    'Add Unit',
                    'gauntlet-generic-popup',
                    'gauntlet-generic-popup-container'
                );

                this.createAddUnitScrollContainer(
                    popupContent,
                    null
                );
            }, this),
            '',
            1
        );
    this.mAddUnitButton.bindTooltip({ contentType: 'msu-generic', modId: ModGauntletEvents.ModID, elementId: "GauntletEditorScreen.FootbarButton.AddUnit" })
    // Save
    this.mSaveButtonLayout =
        $('<div class="gauntlet-text-button-layout"/>');
    this.mFooterButtonBar.append(this.mSaveButtonLayout);
    this.mSaveButton =
        this.mSaveButtonLayout.createTextButton(
            "Save",
            function () {
                var success = self.saveCurrentPool();
                if (!success) {
                    self.createFailedToSavePopup();
                }
            },
            '',
            1
        );
    this.mSaveButton.bindTooltip({ contentType: 'msu-generic', modId: ModGauntletEvents.ModID, elementId: "GauntletEditorScreen.FootbarButton.SavePool" })
    // Start combat
    this.mStartCombatButtonLayout =
        $('<div class="gauntlet-text-button-layout"/>');
    this.mFooterButtonBar.append(this.mStartCombatButtonLayout);
    this.mStartCombatButton =
        this.mStartCombatButtonLayout.createTextButton(
            "Start Combat",
            function () {
                if (!self.isDirty()) {
                    self.createStartCombatPopup();
                    return;
                }

                self.createUnsavedChangesPopup(
                    function () {
                        self.createStartCombatPopup();
                    },
                    function () {
                        self.createStartCombatPopup();
                    }
                );
            },
            '',
            1
        );
    this.mStartCombatButton.bindTooltip({ contentType: 'msu-generic', modId: ModGauntletEvents.ModID, elementId: "GauntletEditorScreen.FootbarButton.StartCombat" });
    // Restore default
    this.mRestoreDefaultButtonLayout =
        $('<div class="gauntlet-text-button-layout"/>');
    this.mFooterButtonBar.append(this.mRestoreDefaultButtonLayout);
    this.mRestoreDefaultButton =
        this.mRestoreDefaultButtonLayout.createTextButton(
            "Restore ALL",
            function () {
                self.restoreDefaultAll();
            },
            '',
            1
        );
    this.mRestoreDefaultButton.bindTooltip({ contentType: 'msu-generic', modId: ModGauntletEvents.ModID, elementId: "GauntletEditorScreen.FootbarButton.RestoreAll" })

    this.addSortIconRow(this.mIconRow);
    this.mIsVisible = false;
};

GauntletPoolEditorScreen.prototype.createInvalidInputPopup = function (_unitName) {
    var title = "Input Validation Failed";
    var message = 'Input validation fails on unit ' + _unitName + '. Please make sure the input fields are correctly typed.'
    this.createStatusPopup(title, message);
}

GauntletPoolEditorScreen.prototype.createFailedToCopyPopup = function () {
    var title = "Copy to clipboard Failed";
    var message = "Copying this pool's data to the clipboard has failed. Please make sure the input fields are valid, and consult the log if this problems persist."
    this.createStatusPopup(title, message)
}

GauntletPoolEditorScreen.prototype.createFailedToSavePopup = function () {
    var title = "Save this Pool Failed";;
    var message = "Saving this pool's data has failed. Please make sure the input fields are correct, and consult the log if this problem persists!";
    this.createStatusPopup(title, message);
}

// Create a simple popup with a title, messages and an OK button 
GauntletPoolEditorScreen.prototype.createStatusPopup = function (_title, _message) {
    if (this.mPopup !== null) {
        console.error("Another popup has taken place!")
        return;
    }
    var content = this.createPopup(
        _title,
        'gauntlet-generic-popup gauntlet-unsaved-popup',
        'gauntlet-generic-popup-container'
    )
    var message = $(
        '<div class="text-font-normal font-color-subtitle gauntlet-unsaved-message">' +
        _message +
        '</div>'
    );
    content.append(message);
}

GauntletPoolEditorScreen.prototype.addTextToContainer = function (_container, _title, _texts) {
    var title = $(
        '<div class="title-font-normal font-color-subtitle gauntlet-help-message"/>'
    );
    title.html("<br><br>" + _title + "<br><br>");
    _container.append(title)

    var message = $(
        '<div class="text-font-normal font-color-description gauntlet-help-message"/>'
    );
    if (_texts instanceof Array) {
        message.html(_texts.join("<br><br>"));
    } else {
        message.html(_texts)
    }
    _container.append(message)
    return _container
}

GauntletPoolEditorScreen.prototype.createHelpPopup = function () {
    var self = this;
    if (this.mPopup !== null) {
        console.error("A popup is already open.");
        return;
    }

    this.mPopup = this.mContainer.createPopupDialog(
        "Help",
        "",
        null,
        "gauntlet-generic-popup"
    );

    this.setPopupDialog(this.mPopup);

    var content = this.mPopup.addPopupDialogContent(
        $('<div class="gauntlet-generic-popup-container"/>')
    );
    var popupListContainer = content.createList(2);
    var scrollContainer = popupListContainer.findListScrollContainer();

    var compositionHelpTitle = "How is the composition of the gauntlet generated?"
    var compositionHelpTexts = [
        'First, the gauntlet calculates the total difficulty rating (DR) score, based on the current day when the gauntlet takes place.\n',
        'Next, it constructs the base pool from either GauntletEarly, GauntletMid or GauntletLate. The gauntlet is chosen based on both the current days and the mod setting for day threshold (for example, GauntletEarly is chosen if current day is lower than the end of earlygame threshold). Then it adds other unit from GauntletChampion, GauntletMiniBoss or GauntletBoss if allowed in the mod settings.\n',
        'Then it filters out units with the Boss, Range or Crowd Control flags into their own separate pools. The gauntlet then starts to construct the composition, starting from Boss -> Range -> Crowd Control -> the rest.\n',
        'Within a pool, it tallies up all units\' weight, and randomly draws units. The weight is treated as biases, with a higher bias means more likelihood of being picked. The drawn unit is then determined if valid to be added to the composition. A unit is valid if adding it would:\n',
        '\t + Not exceed the upper amount of range, crowd control or boss units. This value is random but has an upper limit based on number of gauntlets survived, and has a seperate limit for both certain individual and every unit sharing flags. (Example: at most one necromancer in a fight)\n\n',
        '\t + Not make the total DR of squishy units exceed the squishy limit. This limit accounts for valid range, squishy melee and crowd control units added to the composition. This limit is adjustable in the Mod setting menu.\n',
        '\t + Not exceed the boss\'s DR limit. This limit is adjustable in the Mod setting menu.\n',
        '\t + Guarantee at least a minimum number of units added to the composition. This minimum is based on the current days and party sizes.\n',
        'Only valid units are added. Adding a unit spends scores equal to its DR score. Invalid units are removed from the pool, and when a pool is empty, it then moves to the next one. A base pool (early, mid, late) should have at least one unit with the smallest DR without any special flags to ensure no left-over points and that the minimum number of unit constraint can be satisfiable.\n',
        'After all of the initial DR score is spent or every pool is empty, it then reorganizes unit and returns the final composition for the fight.\n'
    ];

    this.addTextToContainer(
        scrollContainer,
        compositionHelpTitle,
        compositionHelpTexts
    )

    var scalingHelpTitle = "How does the gauntlet scaling work?"
    var scalingHelpTexts = [
        "The gauntlet divides into three \"periods\": early, mid and late. Each period is determined by the threshold set in the Mod Setting menu. The chosen pool and scaling function are different in each period. Pressing the \'Start Combat\' button will give you an estimate for Difficulty Score on the current day.\n",
        "In-depth explanation: Scaling functions are subjected to the days when the gauntlet takes place (Day) and the difficulty modifier (DiffMod). DiffMod is based on the current combat difficulty of the campaign. Currently, the values are 1.2, 1.35 and 1.5 for Beginner, Veteran and Expert respectively\n",
        "d0: Days marking the end of Earlygame\n",
        "d1: Days marking the end of Midgame\n",
        "\t+ Earlygame: when days < d0, Pool used: GauntletEarly. ScoreEarly(Day) = Day * DiffMod",
        "\t+ Midgame: when d0 ≤ Day < d1, Pool used: GauntletMid. ScoreMid(Day) = d0 * DiffMod + (Day - d0) * DiffMod / 2\n",
        "\t+ Lategame: when d1 ≤ Day, Pool used: GauntletLate. ScoreLate(Day) = C*e^(-k*Day).\n",
        "\t   + C and k is calculated such that this function passes (d1, s1) and (d2, s2).\n",
        "\t   + d2: Days when Maximum Score is reached.\n",
        "\t   + s1: The maximum value of Difficulty Score from the Midgame function. In the other word, it's ScoreMid(d1)\n",
        "\t   + s2: The Maximum Difficulty Score.\n",
        "Scaling function will always return within bound of minimum and maximum Difficulty Score. At the moment, it's a WIP. In the future custom scaling might be added.\n"
    ]
    this.addTextToContainer(
        scrollContainer,
        scalingHelpTitle,
        scalingHelpTexts
    )

    this.mPopup.addPopupDialogOkButton(
        function () {
            self.destroyPopupDialog();
            self.mPopup = null;
        },
        false
    )
}

GauntletPoolEditorScreen.prototype.comparePoolOrder = function (_poolA, _poolB) {
    var orders = ModGauntletEvents.GauntletPoolOrder;
    var x = orders.indexOf(_poolA.Name)
    if (x === -1) {
        x = orders.length
    }
    var y = orders.indexOf(_poolB.Name)
    if (y === -1) {
        y = orders.length
    }
    return x - y;
}

GauntletPoolEditorScreen.prototype.getAvailableUnitSubProperties = function (_subpropKey) {
    var unitClass = ModGauntletEvents.UnitProperties;
    var availableSubproperties = [];
    for (var propertyKey in unitClass) {
        var property = unitClass[propertyKey]
        if (property.hasOwnProperty(_subpropKey)) {
            availableSubproperties.push(property[_subpropKey])
        }
    }
    return availableSubproperties
}

GauntletPoolEditorScreen.prototype.getGroupLeaderUnitData = function (_group, _field) {
    var availableId = this.getAvailableUnitSubProperties("Id");
    if (availableId.indexOf(_field) === -1) {
        console.error("UNIT'S FIELD " + _field + " DOES NOT EXIST!");
        return null;
    }
    var group = $(_group); // convert JQuery to DOM?
    var parentRow = group.children(".l-row").first();
    if (parentRow.length === 0) {
        return null;
    }
    var val = null;
    if (_field == ModGauntletEvents.UnitProperties.Name.Id) {
        val = parentRow.find(".name").text();
    } else {
        val = Number(parentRow.data(_field).val());
    }
    if (val === null || val === undefined) {
        console.error("INVALID FIELD'S VALUE INSIDE UNIT! _field=" + _field)
        return null;
    }
    return val;
}

GauntletPoolEditorScreen.prototype.getSortFunctionByFields = function (_field) {
    var self = this;
    var field = _field;
    return function (_unitA, _unitB) {
        var a = self.getGroupLeaderUnitData(_unitA, field);
        var b = self.getGroupLeaderUnitData(_unitB, field);
        if (a < b) {
            return -1;
        } else if (a > b) {
            return 1;
        }
        return 0
    }
}


GauntletPoolEditorScreen.prototype.sortCurrentListByField = function (
    _field
) {
    var self = this;

    var groups = this.mListScrollContainer
        .find(".l-row-group")
        .get();

    groups.sort(this.getSortFunctionByFields(_field));

    $.each(groups, function (_index, _group) {
        self.mListScrollContainer.append(_group);
    });
};

GauntletPoolEditorScreen.prototype.addSortButton = function (
    _parentDiv,
    _field
) {
    var self = this;
    var field = _field;

    this.createOverlayImageButton(
        _parentDiv,
        Asset.BUTTON_SORT,
        function () {
            self.sortCurrentListByField(field);
        },
        "topbar-button-layout",
        6,
        "GauntletEditorScreen.TopbarButton.Sort."
        + this.capitalizeFirstLetter(field)
    );
};

GauntletPoolEditorScreen.prototype.addSortIconRow = function (_parentDiv) {
    var self = this;
    var columnFields = this.getAvailableUnitSubProperties("Id");

    for (var i = 0; i < columnFields.length; i++) {
        var sortButtonContainer = $('<div class="gauntlet-sort-buttons gauntlet-column-absolute-position-' + columnFields[i] + '"/>')
            .appendTo(_parentDiv);
        this.addSortButton(
            sortButtonContainer,
            columnFields[i]
        );
    }

}

GauntletPoolEditorScreen.prototype.addFlagsIconRow = function (_parentDiv) {
    var self = this;
    var iconRow = $(
        '<div class ="flags-icon-container"/>'
    );
    _parentDiv.append(iconRow)

    for (var key in ModGauntletEvents.AvailableFlags) {
        var flag = ModGauntletEvents.AvailableFlags[key];
        var iconLayout = $('<div class="flags-icon-layout"/>');
        iconRow.append(iconLayout);

        var iconPath = Path.GFX + flag.Icon;
        var icon = $('<img class="flags-icon"/>')
            .attr("src", iconPath)
            .appendTo(iconLayout);

        var iconTooltip = "GauntletEditorScreen.Flags." + flag.Tooltip;
        icon.bindTooltip({ contentType: 'msu-generic', modId: ModGauntletEvents.ModID, elementId: iconTooltip })

        var iconFilterButton = this.addFlagFilterButton(iconLayout, key)
        this.mFlagFilterButtons[key] = iconFilterButton
    }
    return iconRow
}

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

GauntletPoolEditorScreen.prototype.updatePoolMetadata = function () {
    var self = this;
    var leaderCount = this.mListScrollContainer.children(".l-row-group").length;
    var weightId = ModGauntletEvents.UnitProperties.Weight.Id;
    var weightType = ModGauntletEvents.UnitProperties.Weight.Type;
    var totalWeight = 0;
    var totalWeightVisible = 0;
    this.mListScrollContainer.children(".l-row-group").each(
        function () {
            var group = $(this);
            var parentRow = group.children(".l-row").first();
            if (parentRow.length === 0) {
                return;
            }
            var input = parentRow.data(weightId);
            if (self.validateInput(input, weightType)) {
                totalWeight += Number(input.val());
                totalWeightVisible +=
                    group.hasClass(ModGauntletEvents.DisplayHiddenClass) ?
                        0 : Number(input.val());
            }
        }
    )

    this.mDialogContainer.findDialogSubTitle().text(
        "The pool " +
        this.mSelectedPool.Name +
        " contains " +
        leaderCount +
        " units, and a total weight of " +
        parseFloat(totalWeight.toPrecision(6)) +
        " for all units, " +
        parseFloat(totalWeightVisible.toPrecision(6)) +
        " for currently visible units"
    );
}

GauntletPoolEditorScreen.prototype.addInputFieldToTable = function (
    _parent,
    _property,
    _value,
    _callback
) {
    var self = this;

    var inputLayout = $('<div class="gauntlet-short-input-container"/>');
    var input = $(
        '<input type="text" class="title-font-normal font-color-subtitle short-input"/>'
    );

    inputLayout.addClass(_property.ClassName);
    input.val(_value);

    if (_callback !== "undefined" && _callback !== "null") {
        input.on("input", function () {
            var valid = self.validateInput(input, _property.Type)
            if (valid) {
                input.removeClass("is-invalid")
            } else {
                input.addClass("is-invalid")
            }
            _callback();
        });
    } else {
        input.on("input", function () {
            var valid = self.validateInput(input, _property.Type)
            input.toggleClass("is-invalid", !valid);
        });
    }

    _parent.append(inputLayout);
    inputLayout.append(input);
    _parent.data(_property.Id, input);
    return inputLayout;
};

GauntletPoolEditorScreen.prototype.validateInput = function (
    _input,
    _type
) {
    if (_type === null || _type === undefined) {
        console.error("WARNING: undefined type when type-checking! Assuming Integer.")
        _type = "Integer";
    }
    var value = _input.val();
    // this mess is because we cannot use 
    // Number.isInteger and Number.isFinite,
    // since those functions don't exist
    if (_type === "Integer") {
        var num = Number(value);
        if (num === NaN) {
            return false;
        }
        if (num - parseInt(num, 10) !== 0) {
            return false
        }
        return num > 0;
    }

    if (_type === "Number") {
        var num = Number(value);
        if (num === NaN) {
            return false;
        }
        return num > 0;
    }

    return true;
}

GauntletPoolEditorScreen.prototype.addCheckbox = function (
    _parent,
    _class,
    _title,
    _id,
    _isChecked,
    _isLocked
) {
    var containerClass = (_class !== null && _class !== undefined) ?
        _class : $('<div class="gauntlet-checkbox-container"/>');

    var checkboxContainer = $(
        '<div class="' + containerClass + '"/>'
    );
    _parent.append(checkboxContainer);

    var checkboxTitle = $('<div class="title text-font-normal font-color-title">' + _title + '</div>')
    checkboxContainer.append(checkboxTitle)

    var checkbox = $(
        '<input class="gauntlet-checkbox" ' + ' type="checkbox" id="' +
        _id +
        '"/>'
    ).appendTo(checkboxContainer);

    checkbox.iCheck({
        checkboxClass: 'icheckbox_flat-orange',
        radioClass: 'iradio_flat-orange',
        increaseArea: '30%'
    });

    var label = $(
        '<label class="bool-checkbox-label" for="' + _id + '"/>'
    );

    checkboxContainer.append(label);

    if (_isChecked === true) {
        checkbox.iCheck('check');
    } else {
        checkbox.iCheck('uncheck');
    }

    label.on("click", function () {
        var checkboxForLabel = $("#" + $(this).attr("for"));

        if (!checkboxForLabel.attr("disabled")) {
            checkboxForLabel.iCheck("toggle");
        }
    });

    if (_isLocked === true) {
        checkbox.iCheck("disable");
    }

    return checkbox
}

GauntletPoolEditorScreen.prototype.addFlagCheckboxes = function (
    _parent,
    _flags,
    _lockedFlags
) {
    var self = this;
    var flagSet = {};
    var lockedFlagSet = {};

    if (Array.isArray(_flags)) {
        for (var i = 0; i < _flags.length; ++i) {
            flagSet[_flags[i]] = true;
        }
    }

    if (Array.isArray(_lockedFlags)) {
        for (var i = 0; i < _lockedFlags.length; ++i) {
            lockedFlagSet[_lockedFlags[i]] = true;
        }
    }

    var container = $('<div class="gauntlet-checkbox-container"/>');
    _parent.append(container);

    var checkboxMap = {};

    for (var flag in ModGauntletEvents.AvailableFlags) {
        var checkboxContainer = $(
            '<div class="gauntlet-checkbox-layout"/>'
        );

        container.append(checkboxContainer);

        var id = "gauntlet-flag-" +
            flag +
            "-" +
            this.mListScrollContainer.find(".l-row-group").length +
            "-" +
            i;

        var checkbox = $(
            '<input class="gauntlet-checkbox" type="checkbox" id="' +
            id +
            '"/>'
        ).appendTo(checkboxContainer);

        checkbox.iCheck({
            checkboxClass: 'icheckbox_flat-orange',
            radioClass: 'iradio_flat-orange',
            increaseArea: '30%'
        });

        checkbox.on(
            'ifChecked ifUnchecked',
            function () {
                self.markDirty();
            }
        );

        var label = $(
            '<label class="bool-checkbox-label" for="' + id + '"/>'
        );

        checkboxContainer.append(label);

        if (flagSet[flag] === true) {
            checkbox.iCheck('check');
        } else {
            checkbox.iCheck('uncheck');
        }

        label.on("click", function () {
            var checkboxForLabel = $("#" + $(this).attr("for"));

            if (!checkboxForLabel.attr("disabled")) {
                checkboxForLabel.iCheck("toggle");
            }
        });

        if (lockedFlagSet[flag] === true) {
            checkbox.iCheck('check');
            checkbox.iCheck("disable");
        }

        checkboxMap[flag] = checkbox;
    }

    _parent.data("flagCheckboxes", checkboxMap);

    return container;
};

// Source - https://stackoverflow.com/a/32108184
// Posted by Adam Zerner, modified by community. See post 'Timeline' for change history
// Retrieved 2026-09-01, License - CC BY-SA 4.0
GauntletPoolEditorScreen.prototype.isEmpty = function isEmpty(obj) {
    for (var prop in obj) {
        if (Object.prototype.hasOwnProperty.call(obj, prop)) {
            return false;
        }
    }

    return true
}



GauntletPoolEditorScreen.prototype.getFlagsFromRow = function (_row, _queryFlags) {
    var checkboxMap = _row.data("flagCheckboxes");

    if (checkboxMap === undefined || checkboxMap === null) {
        return [];
    }

    var flags = [];
    var queriedFlags = _queryFlags
    if (queriedFlags === null || queriedFlags === undefined) {
        queriedFlags = ModGauntletEvents.AvailableFlags; // assume query all flags
    }
    // queryFlags MUST BE KEYPAIR
    for (var flag in queriedFlags) {
        var checkbox = checkboxMap[flag];
        if (checkbox !== undefined &&
            checkbox !== null &&
            checkbox.prop("checked") === true
        ) {
            flags.push(flag);
        }
    }
    return flags;
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
    result.data("unitname", name);

    result.rowButtonCallback = function () {
        self.onTableInputChanged();
    }
    var property = ModGauntletEvents.UnitProperties;
    this.addInputFieldToTable(
        result,
        property.Num,
        _data.Num,
        result.rowButtonCallback
    );

    this.addInputFieldToTable(
        result,
        property.DifficultyRating,
        _data.DifficultyRating,
        result.rowButtonCallback
    );

    this.addInputFieldToTable(
        result,
        property.Weight,
        _data.Weight,
        function () {
            result.rowButtonCallback();
            self.updatePoolMetadata();
        }
    );

    this.addFlagCheckboxes(
        result,
        _data.Flags,
        this.mSelectedPool.ForceFlags
    );

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
    result.rowButtonCallback = function () {
        self.onTableInputChanged();
    }
    var property = ModGauntletEvents.CoSpawnProperties
    this.addInputFieldToTable(
        result,
        property.Num,
        _data.Num,
        result.rowButtonCallback
    );

    var actions = $('<div class="gauntlet-row-actions"/>');
    result.append(actions);
    this.createRowActionButton(
        actions,
        Asset.BUTTON_DISMISS_CHARACTER,
        "GauntletEditorScreen.UnitRowButton.DeleteRow",
        function () {
            self.markDirty();
            result.remove();
        }
    );

    return result;
};

// Implementation from CombatSimulator
GauntletPoolEditorScreen.prototype.copyData = function (_obj) {
    var str = JSON.stringify(_obj);
    var input = $('<input type="text"/>').appendTo(this.mDialogContainer);
    input.val(str);
    input.select();
    input.focus();
    document.execCommand('copy');
    input.remove();
}

// Implementation from CombatSimulator
GauntletPoolEditorScreen.prototype.pasteData = function () {
    var input = $('<input type="text"/>').appendTo(this.mDialogContainer);
    input.select();
    input.focus();
    document.execCommand('paste');
    var ret = input.val();
    input.remove();
    return ret;
}

GauntletPoolEditorScreen.prototype.copyCurrentPoolDataToClipboard = function () {
    var pool = this.collectCurrentPoolData();
    if (pool === null) {
        console.error("Failed to collect pool data!");
        return false
    }
    this.copyData(pool);
    return true;
}

GauntletPoolEditorScreen.prototype.pastePoolDataFromClipboard = function () {
    var self = this;
    this.mColumnButtons.pasteCallback = function () {
        var success = self.setPoolDataFromString(self.pasteData())
        self.markDirty();
        if (!success) {
            self.discardCurrentPoolChanges();
            self.createStatusPopup(
                "Paste pool data Failed",
                "Failed to paste and parse data copied from clipboard. Please make sure the copied JSON is valid and consult the logs if the problems persist."
            )
        }
    }
    this.confirmDiscardBefore(this.mColumnButtons.pasteCallback)
}

GauntletPoolEditorScreen.prototype.setPoolDataFromString = function (_string) {
    var self = this;
    try {
        var data = JSON.parse(_string);
        this.resetAndFillUnitTables(data);
    } catch (exception) {
        console.error("Failed to parseData from string.")
        console.error(exception)
        return false
    }
    return true;
}


GauntletPoolEditorScreen.prototype.collectCurrentPoolData = function () {
    var self = this;
    var pool = {
        Name: this.mSelectedPool.Name,
        Troops: []
    };

    var rows = this.mListScrollContainer.find(".l-row-group");
    var isInputValid = true;
    try {
        rows.each(function () {
            var group = $(this);
            var parentRow = group.children(".l-row").first();
            if (parentRow.length === 0) {
                return;
            }
            var unitProperty = ModGauntletEvents.UnitProperties
            var unitName = parentRow.find(".name").text();
            var numInput = parentRow.data(unitProperty.Num.Id);
            var drInput = parentRow.data(unitProperty.DifficultyRating.Id);
            var weightInput = parentRow.data(unitProperty.Weight.Id);

            var validInput = self.validateInput(numInput, unitProperty.Num.Type)
                && self.validateInput(drInput, unitProperty.DifficultyRating.Type)
                && self.validateInput(weightInput, unitProperty.Weight.Type);
            if (!validInput) {
                var error = "VALIDATING FAILED ON UNIT " + unitName;
                self.mLastInvalidInput = unitName;
                isInputValid = false;
                throw error;
            }

            var troop = {
                Name: unitName,
                Num: String(Number(numInput.val())),
                DifficultyRating: String(Number(drInput.val())),
                Weight: String(Number(weightInput.val())),
                Flags: self.getFlagsFromRow(parentRow),
                CoSpawn: []
            }


            group.children(".co-spawn-row").each(function () {
                var coSpawnRow = $(this);

                var coSpawnUnitName = coSpawnRow.find(".name").first()
                    .text().replace(/^└─\s*/, "");
                var coSpawnNumInput = coSpawnRow.data("num");

                var validInput = self.validateInput(coSpawnNumInput, "Integer")
                if (!validInput) {
                    var error = "VALIDATING FAILED ON CO-SPAWN " + coSpawnUnitName;
                    self.mLastInvalidInput = unitName + "'s cospawn: " + coSpawnUnitName;
                    isInputValid = false;
                    throw error;
                }

                troop.CoSpawn.push({
                    Name: coSpawnUnitName,
                    Num: String(Number(coSpawnNumInput.val()))
                });
            });

            pool.Troops.push(troop);
        });
    } catch (error) {
        console.error("FAILED TO COLLECT UNITS DATA!")
        console.error(error);
        if (!isInputValid) {
            this.createInvalidInputPopup(this.mLastInvalidInput)
        }
        return null;
    }


    this.mLastInvalidInput = null;
    return pool;
};

GauntletPoolEditorScreen.prototype.notifyBackendOnSaveCurrentPool = function (
    _pool
) {
    // console.error("Sending Weight:" + _pool.Troops[0].Weight);
    // console.error("Sending DR:" + _pool.Troops[0].DifficultyRating);
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
    if (pool === null) {
        console.error("Failed to collect pool data!");
        return false
    }

    var success = this.notifyBackendOnSaveCurrentPool(pool);

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
    this.createWarningPopup(
        "Unsaved Changes",
        'You have unsaved changes to this pool. What would you like to do?'
    )

    var footerButtonBar = this.mPopup
        .findPopupDialogFooterContainer();
    footerButtonBar.children().first().remove(); // remove default l-button-row

    var saveButtonLayout = $('<div class="popup-text-button-layout"/>');
    footerButtonBar.append(saveButtonLayout)

    var saveButton = saveButtonLayout.createTextButton(
        "Save",
        function () {
            var saved = self.saveCurrentPool();

            self.destroyPopupDialog();
            self.mPopup = null;

            if (!saved) {
                self.createFailedToSavePopup()
                return;
            }

            if (_onSave !== undefined && _onSave !== null) {
                _onSave();
            }
        },
        '',
        1
    )
    saveButtonLayout.append(saveButton)

    var discardButtonLayout = $('<div class="popup-text-button-layout"/>');
    footerButtonBar.append(discardButtonLayout)

    var discardButton = discardButtonLayout.createTextButton(
        "Discard",
        function () {
            self.discardCurrentPoolChanges();

            self.destroyPopupDialog();
            self.mPopup = null;

            if (_onDiscard !== undefined && _onDiscard !== null) {
                _onDiscard();
            }
        },
        '',
        1
    )

    var cancelButtonLayout = $('<div class="popup-text-button-layout"/>');
    footerButtonBar.append(cancelButtonLayout)

    var cancelButton = cancelButtonLayout.createTextButton(
        "Cancel",
        function () {
            self.destroyPopupDialog();
            self.mPopup = null;
        },
        '',
        1
    )

};

GauntletPoolEditorScreen.prototype.resetAndFillUnitTables = function (_data, _setClean) {
    this.mListScrollContainer.empty();

    for (var i = 0; i < _data.Troops.length; ++i) {
        this.addListEntry(_data.Troops[i]);
    }
    if (_setClean) {
        this.markClean();
    }
    this.updatePoolMetadata();
    this.resetToNoFilterState();
}


GauntletPoolEditorScreen.prototype.discardCurrentPoolChanges = function () {
    if (this.mSelectedPool === null) {
        return;
    }
    //mSelectedPool represents the last saved version of this pool.
    this.resetAndFillUnitTables(this.mSelectedPool, true)
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
    this.resetAndFillUnitTables(_selectedEntry, true);
};

GauntletPoolEditorScreen.prototype.createRowActionButton = function (
    _parent,
    _asset,
    _tooltip,
    _callback,
    _layout_class,
    _button_class
) {
    var layout = $('<div class="action-button-layout"/>');
    if (_layout_class !== null && _layout_class !== undefined) {
        layout = $('<div class=' + _layout_class + '/>')
    }
    _parent.append(layout);

    var button = $('<img class="action-button"/>');
    if (_button_class !== null && _button_class !== undefined) {
        button = $('<img class=\"' + _button_class + '\"/>');
    }

    button.attr("src", Path.GFX + _asset)
        .appendTo(layout);

    if (_tooltip != null) {
        button.bindTooltip({ contentType: 'msu-generic', modId: ModGauntletEvents.ModID, elementId: _tooltip })
    }

    button.on("click", _callback);

    return button;
};


GauntletPoolEditorScreen.prototype.capitalizeFirstLetter = function (val) {
    return String(val).charAt(0).toUpperCase() + String(val).slice(1);
}


GauntletPoolEditorScreen.prototype.createOverlayImageButton = function (
    _container,
    _icon,
    _callback,
    _class,
    _size,
    _tooltip
) {
    var buttonLayoutClass = ("l-image-button " + _class).trim()
    var button = _container.createImageButton(Path.GFX + _icon, _callback, buttonLayoutClass, _size);
    if (_tooltip !== null && _tooltip !== undefined) {
        button.bindTooltip({
            contentType: 'msu-generic',
            modId: ModGauntletEvents.ModID,
            elementId: _tooltip
        })
    }
    return button
}

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
        "GauntletEditorScreen.UnitRowButton.DeleteRow",
        function () {
            self.markDirty();

            if (_group !== null && _group !== undefined) {
                _group.remove();
                self.updatePoolMetadata();
            } else {
                _row.remove();
            }
        }
    );

    if (_group !== null && _group !== undefined) {
        this.createRowActionButton(
            actions,
            Asset.BUTTON_TOGGLE_TREES_ENABLED,
            "GauntletEditorScreen.UnitRowButton.AddCospawn",
            function () {
                var popupContent = self.createPopup(
                    'Add Unit',
                    'gauntlet-generic-popup',
                    'gauntlet-generic-popup-container'
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
};

GauntletPoolEditorScreen.prototype.register = function (_parentDiv) {
    console.log('GauntletPoolEditorScreen::REGISTER');

    if (this.mContainer !== null) {
        console.error('ERROR: Failed to register Relations GauntletEditorScreen. Reason: Already initialized.');
        return;
    }

    if (_parentDiv !== null && typeof (_parentDiv) == 'object') {
        this.create(_parentDiv);
    }
};

GauntletPoolEditorScreen.prototype.unregister = function () {
    console.log('GauntletPoolEditorScreen::UNREGISTER');

    if (this.mContainer === null) {
        console.error('ERROR: Failed to unregister Relations GauntletEditorScreen. Reason: Not initialized.');
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

GauntletPoolEditorScreen.prototype.doStartAnimation = function () {
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
}

GauntletPoolEditorScreen.prototype.show = function (_data) {
    this.loadFromData(_data);
    this.doStartAnimation();
};

GauntletPoolEditorScreen.prototype.showFailedToFetchData = function () {
    this.doStartAnimation();
    var popup = this.createWarningPopup(
        "Loading Failed",
        "Loading the gauntlet data from the file has failed. Press \'OK\' to restore to the default data. If unsured, please make a backup before proceeding."
    )

    popup.addPopupDialogOkButton(
        function () {
            self.notifyBackendOnRestoreDefaultAll();

            self.destroyPopupDialog();
            self.mPopup = null;
        },
        false
    );

    popup.addPopupDialogCancelButton(
        function () {
            self.destroyPopupDialog();
            self.mPopup = null;
            if (this.mSQHandle !== null) {
                SQ.call(this.mSQHandle, "onClose", _buttonID);
            }
        },
        false
    );
}

GauntletPoolEditorScreen.prototype.doEndAnimation = function (_withSlideAnimation) {
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
}

GauntletPoolEditorScreen.prototype.hide = function (_withSlideAnimation) {
    this.discardCurrentPoolChanges();
    this.doEndAnimation();
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

    // this.confirmDiscardBefore(this.switchToPool)
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
    this.mData.Pools.sort(this.comparePoolOrder);
    // Set default pool
    var defaultPool = this.mData.Pools[0];
    if ("PreviousPoolPicked" in this.mData && this.mData.PreviousPoolPicked !== null) {
        var previousPool = null;
        for (var i = 0; i < this.mData.Pools.length; i++) {
            var pool = this.mData.Pools[i]
            if (pool.Name === this.mData.PreviousPoolPicked) {
                previousPool = pool;
                break;
            }
        }
        if (previousPool !== null) {
            defaultPool = previousPool;
        }
    }
    var self = this;
    this.mDropdownContainer.set(
        this.mData.Pools,
        defaultPool,
        function (_selectedEntry) {
            self.onChangeEntry(_selectedEntry);
        }
    );
};

GauntletPoolEditorScreen.prototype.getUnitLeaderFromGroup = function (_group) {
    var group = $(_group);
    var parentRow = group.children(".l-row").first();
    return parentRow
}

GauntletPoolEditorScreen.prototype.toggleVisibilityOfUnitsBasedOnFilters = function () {
    var self = this;
    var groups = this.mListScrollContainer.find(".l-row-group");
    groups.each(function () {
        var group = $(this);
        var unitLeader = group.children(".l-row").first();

        if (self.canShowUnitBasedOnFilters(unitLeader)) {
            group.removeClass(ModGauntletEvents.DisplayHiddenClass)
        } else {
            group.addClass(ModGauntletEvents.DisplayHiddenClass)
        }
    })
    this.updatePoolMetadata()
}

GauntletPoolEditorScreen.prototype.doesArrayContainObjKeys = function (_arr, _obj) {
    for (var key in _obj) {
        if (_arr.indexOf(key) === -1) {
            return false;
        }
    }
    return true;
}

GauntletPoolEditorScreen.prototype.doesArrayExcludeObjKeys = function (_arr, _obj) {
    for (var key in _obj) {
        if (_arr.indexOf(key) !== -1) {
            return false
        }
    }
    return true;
}

GauntletPoolEditorScreen.prototype.canShowUnitBasedOnFilters = function (_unit) {
    var unitFlags = this.getFlagsFromRow(_unit)

    return this.doesArrayContainObjKeys(unitFlags, this.mIncludeFilters) &&
        this.doesArrayExcludeObjKeys(unitFlags, this.mExcludeFilters)
}

GauntletPoolEditorScreen.prototype.getButtonStateIdxName = function (_flagKey) {
    return "stateIdx" + _flagKey
}

GauntletPoolEditorScreen.prototype.getFilterButtonFromContainer = function (_flagContainer, _flagKey) {
    _flagContainer.find()
}

GauntletPoolEditorScreen.prototype.advanceFilterState = function (
    _flagKey
) {
    var filterStates = ModGauntletEvents.FilterState
    var states = []
    for (var key in filterStates) {
        states.push(filterStates[key].Id)
    }

    var buttonStateIdxName = this.getButtonStateIdxName(_flagKey)
    // advance state idx
    var stateIdx = this.mColumnFlags.data(buttonStateIdxName);
    stateIdx = (stateIdx + 1) % states.length;
    this.mColumnFlags.data(buttonStateIdxName, stateIdx);

    this.handleFilterStateTransition(states[stateIdx], _flagKey)
}

GauntletPoolEditorScreen.prototype.handleFilterStateTransition = function (
    _nextState,
    _flagKey
) {
    var filterStates = ModGauntletEvents.FilterState
    var buttonImage = this.mFlagFilterButtons[_flagKey].find('img')
    for (var key in filterStates) {
        if (_nextState === filterStates[key].Id) {
            filterStates[key].doStateTransition(_flagKey, this.mIncludeFilters, this.mExcludeFilters);
            buttonImage.attr('src', Path.GFX + filterStates[key].Icon)
            break;
        }
    }
    // if (_nextState === filterStates.Include.Id) {
    //     this.mIncludeFilters[_flagKey] = ModGauntletEvents.AvailableFlags[_flagKey]
    //     buttonImage.attr('src', Path.GFX + filterStates.Include.Icon)
    // }
    // if (_nextState === filterStates.Exclude.Id) {
    //     delete this.mIncludeFilters[_flagKey];
    //     this.mExcludeFilters[_flagKey] = ModGauntletEvents.AvailableFlags[_flagKey];
    //     buttonImage.attr('src', Path.GFX + filterStates.Exclude.Icon)
    // }
    // if (_nextState === filterStates.NoFilter.Id) {
    //     delete this.mExcludeFilters[_flagKey];
    //     buttonImage.attr('src', Path.GFX + filterStates.NoFilter.Icon)
    // }
}

GauntletPoolEditorScreen.prototype.resetToNoFilterState = function () {
    this.mIncludeFilters = {}
    this.mExcludeFilters = {}
    for (var flagKey in ModGauntletEvents.AvailableFlags) {
        this.mColumnFlags.data(this.getButtonStateIdxName(flagKey), 0)
        var buttonImage = this.mFlagFilterButtons[flagKey].find('img');
        buttonImage.attr(
            'src',
            Path.GFX + ModGauntletEvents.FilterState.NoFilter.Icon
        )
    }
}


GauntletPoolEditorScreen.prototype.addFlagFilterButton = function (
    _container,
    _flagName
) {
    var self = this;
    var button = this.createOverlayImageButton(
        _container,
        'ui/icons/nofilter.png',
        function () {
            self.advanceFilterState(_flagName)
            self.toggleVisibilityOfUnitsBasedOnFilters()
        },
        '',
        0,
        "GauntletEditorScreen.Filters"
    )
    return button;
}

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
    var row = $('<div class="title-font-normal font-color-subtitle gauntlet-entry-label"></div>')
        .html(_text)
        .addClass(_classes)
    if (_isTitle === true)
        row.removeClass("font-color-subtitle").addClass("font-color-brother-name")
    return row;
}


GauntletPoolEditorScreen.prototype.addRow = function (_div, _classes, _divider) {
    var row = $('<div class="gauntlet-row"/>');
    _div.append(row);
    if (_classes != undefined) {
        row.addClass(_classes);
    }
    if (_divider === true) {
        row.addClass("gauntlet-bottom-gold-line");
    }
    return row;
}


GauntletPoolEditorScreen.prototype.createFilterBar = function (_scrollContainer) {
    var row = $('<div class="gauntlet-filter-bar"/>');
    var name = this.getTextDiv("Filter")
        .appendTo(row);
    var filterLayout = $('<div class="gauntlet-filter-input-container"/>')
        .appendTo(row);
    var filterInput = $('<input type="text" class="title-font-normal font-color-brother-name"/>')
        .appendTo(filterLayout)
        .on("keyup", function (_event) {
            var currentInput = $(this).val();
            var rows = _scrollContainer.find(".gauntlet-row");
            rows.each(function (_idx) {
                var label = $(this).find(".gauntlet-entry-label");
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

        var name = $('<div class="title-font-normal font-color-subtitle gauntlet-entry-label">' + _unit.DisplayName + '</div>');
        row.append(name);

        var addButtonContainer = $('<div class="gauntlet-text-button-layout"/>');
        var addButton = addButtonContainer.createTextButton("Add", $.proxy(function (_button) {
            var data = {
                "Name": _unit.DisplayName,
                "Num": 1,
                "Weight": 1,
                "DifficultyRating": 1
            }
            if (_coSpawnGroup === null) {
                this.addListEntry(data)
                this.updatePoolMetadata()
            } else {
                this.addCoSpawnEntry(_coSpawnGroup, data)
            }
            this.markDirty();
            this.focusActiveFilterBar();
        }, self), "gauntlet-text-button", 4);
        // addButton.bindTooltip({ contentType: 'msu-generic', modId: gauntletulator.ModID, elementId: "GauntletEditorScreen.Units.Main.Add"});

        row.append(addButtonContainer);
    }, this))
    this.focusActiveFilterBar();
}

GauntletPoolEditorScreen.prototype.createWarningPopup = function (
    _title,
    _message
) {
    var self = this;
    if (this.mPopup !== null) {
        console.error("A popup is already open.");
        return;
    }

    this.mPopup = this.mContainer.createPopupDialog(
        _title,
        "",
        null,
        "gauntlet-generic-popup gauntlet-unsaved-popup"
    );

    this.setPopupDialog(this.mPopup);

    var content = this.mPopup.addPopupDialogContent(
        $('<div class="gauntlet-generic-popup-container"/>')
    );

    var message = $(
        '<div class="title-font-normal font-color-subtitle gauntlet-unsaved-message">' +
        _message +
        '</div>'
    );
    content.append(message);

    return this.mPopup
}

GauntletPoolEditorScreen.prototype.startCombat = function () {
    // collect combat setting
    var content = this.mPopup.find(".gauntlet-generic-popup-container")

    var days = content.data(ModGauntletEvents.CombatSetting.Days.Id);
    var diffScore = content.data(ModGauntletEvents.CombatSetting.DifficultyScore.Id);
    var checkBoxMap = content.data("combatSettingCheckboxes");
    var allowLootingCheckbox = checkBoxMap["gauntlet-checkbox-allowlooting"];
    var giveSuppliesCheckbox = checkBoxMap["gauntlet-checkbox-allowsupplies"];

    var combatSetting = {
        Days: Number(days.val()),
        DifficultyScore: Number(diffScore.val()),
        AllowLooting: allowLootingCheckbox.prop("checked") === true,
        GiveSupplies: giveSuppliesCheckbox.prop("checked") === true,
    }
    MSU.printData(combatSetting, 1, 255)
    this.notifyBackendOnStartCombat(combatSetting)
}

GauntletPoolEditorScreen.prototype.createStartCombatPopup = function () {
    var self = this;
    var combatSetting = this.mData.InitialCombatSetting;
    if (this.mPopup !== null) {
        console.error("A popup is already open.");
        return;
    }
    this.mPopup = this.mContainer.createPopupDialog(
        "Initializing Gauntlet Combat",
        "",
        null,
        "gauntlet-combat-start-popup"
    );

    this.setPopupDialog(this.mPopup);

    this.mPopup.find("sub-title").remove()

    var content = this.mPopup.addPopupDialogContent(
        $('<div class="gauntlet-generic-popup-container"/>')
    );
    // difficulty score
    var diffScoreContainer = $('<div class="gauntlet-popup-input-container">')
        .appendTo(content);
    diffScoreContainer.append(
        '<div class="title text-font-normal font-color-title">'
        + "Difficulty Score" +
        '<div/>'
    )
    var diffScoreProperty = ModGauntletEvents.CombatSetting.DifficultyScore
    this.addInputFieldToTable(
        diffScoreContainer,
        diffScoreProperty,
        combatSetting.DifficultyScore,
        null
    ).bindTooltip({ contentType: 'msu-generic', modId: ModGauntletEvents.ModID, elementId: "GauntletEditorScreen.CombatPopup.DifficultyScore" })
    content.data(diffScoreProperty.Id, diffScoreContainer.data(diffScoreProperty.Id)) // real clunky, i know
    // days
    var daysContainer = $('<div class="gauntlet-popup-input-container">')
        .appendTo(content);
    daysContainer.append(
        '<div class="title text-font-normal font-color-title">'
        + "Days combat taken place" +
        '<div/>'
    )
    var daysProperty = ModGauntletEvents.CombatSetting.Days
    this.addInputFieldToTable(
        daysContainer,
        daysProperty,
        combatSetting.Days,
        null
    ).bindTooltip({ contentType: 'msu-generic', modId: ModGauntletEvents.ModID, elementId: "GauntletEditorScreen.CombatPopup.Days" })
    content.data(daysProperty.Id, daysContainer.data(daysProperty.Id))
    // TODO: booleans allowlooting allowsupplies checkboxes
    var checkboxMap = {};
    // allow looting
    var allowLootingId = "gauntlet-checkbox-allowlooting"
    var allowLootingCheckbox = this.addCheckbox(
        content,
        "gauntlet-popup-checkbox-container",
        "Allow enemies gears drop",
        allowLootingId,
        combatSetting.AllowLooting,
        false
    )
    allowLootingCheckbox.bindTooltip({ contentType: 'msu-generic', modId: ModGauntletEvents.ModID, elementId: "GauntletEditorScreen.CombatPopup.AllowLooting" });
    checkboxMap[allowLootingId] = allowLootingCheckbox;
    // allow supplies
    var giveSuppliesId = "gauntlet-checkbox-allowsupplies";
    var giveSuppliesCheckbox = this.addCheckbox(
        content,
        "gauntlet-popup-checkbox-container",
        "Give supplies compensation",
        giveSuppliesId,
        combatSetting.GiveSupplies,
        false
    )
    giveSuppliesCheckbox.bindTooltip({ contentType: 'msu-generic', modId: ModGauntletEvents.ModID, elementId: "GauntletEditorScreen.CombatPopup.GiveSupplies" })
    checkboxMap[giveSuppliesId] = giveSuppliesCheckbox;

    content.data("combatSettingCheckboxes", checkboxMap)

    this.mPopup.addPopupDialogOkButton(
        function () {
            self.startCombat();

            self.destroyPopupDialog();
            self.mPopup = null;
        },
        false
    )

    this.mPopup.addPopupDialogCancelButton(
        function () {
            self.destroyPopupDialog();
            self.mPopup = null;
        },
        false
    );
}

GauntletPoolEditorScreen.prototype.createRestoreDefaultThisPopup = function () {
    var self = this;
    this.createWarningPopup(
        "Restoring to default data",
        'You are about to restore the data of this pool to its default value. Confirm?'
    )

    this.mPopup.addPopupDialogOkButton(
        function () {
            self.discardCurrentPoolChanges();

            var poolName = self.mSelectedPool.Name
            self.notifyBackendOnRestoreDefaultThis(poolName);

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

GauntletPoolEditorScreen.prototype.createRestoreDefaultAllPopup = function () {
    var self = this;
    this.createWarningPopup(
        "Restoring to default data",
        'You are about to restore the data of **EVERY POOL** to their default value. Confirm?'
    )

    this.mPopup.addPopupDialogOkButton(
        function () {
            self.discardCurrentPoolChanges();
            self.notifyBackendOnRestoreDefaultAll();

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

GauntletPoolEditorScreen.prototype.restoreDefaultThis = function () {
    this.createRestoreDefaultThisPopup()
}

GauntletPoolEditorScreen.prototype.restoreDefaultAll = function () {
    this.createRestoreDefaultAllPopup();
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

GauntletPoolEditorScreen.prototype.notifyBackendOnRestoreDefaultThis = function (_poolName) {
    if (this.mSQHandle !== null) {
        SQ.call(this.mSQHandle, 'onRestoreDefault', _poolName);
    }
}

GauntletPoolEditorScreen.prototype.notifyBackendOnRestoreDefaultAll = function () {
    if (this.mSQHandle !== null) {
        SQ.call(this.mSQHandle, 'onRestoreDefaultAll');
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

GauntletPoolEditorScreen.prototype.notifyBackendOnStartCombat = function (_combatSetting) {
    if (this.mSQHandle !== null) {
        SQ.call(this.mSQHandle, 'onStartCombat', _combatSetting);
    }
}

registerScreen("GauntletPoolEditorScreen", new GauntletPoolEditorScreen());