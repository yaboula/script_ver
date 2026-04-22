-- English
local Translations = {
    general = {
        interaction = "Outfit Changer",
        title_1 = "OUTFIT",
        title_2 = "CHANGER",
        description = "CREATE YOUR UNIQUE CHARACTER EXACTLY HOW YOU IMAGINE IT NOW",
        list_of_outfits = "List of Outfits",
        manage_your_outfits = "Manage your outfits",
        search_outfit = "Search outfit...",
        adjust_camera = "Adjust your camera",
        click_to_rotate = "Click + left/right to rotate",
        use_arrow_to_rotate = "Use arrow keys to rotate",
        click_to_adjust_height = "Click + up/down to adjust height",
        scroll_to_adjust_zoom = "Scroll to adjust zoom",
        edit_outfit = "Edit Outfit",
        edit_outfit_2 = "Edit the selected outfit",
        save_changes = "Save Changes",
        create_outfit = "Create Outfit",
        create_outfit_2 = "Create a new outfit",
        outfit_name = "Outfit name",
        outfit_tags = "Tags (seperated by commas)",
        no_tags = "No Tags",
        delete_outfit = "Delete Outfit",
        delete_outfit_2 = "Are you sure you want to delete this outfit?",
        cancel = "Cancel"
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})