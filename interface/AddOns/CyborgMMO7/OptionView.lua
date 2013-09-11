OptionView = {
	new = function(self)
	 -- Set the name for the Category for the Panel
        --
        self.name = "Cyborg MMO7 Plugin"

        -- When the player clicks okay, run this function.
        --
        --self.okay = function (self) SC_ChaChingPanel_Close(); end;

        -- When the player clicks cancel, run this function.
        --
        --self.cancel = function (self)  SC_ChaChingPanel_CancelOrLoad();  end;

        -- Add the panel to the Interface Options
        --
        InterfaceOptions_AddCategory(self);
		return self

	end
}
