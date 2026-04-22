Config = {}

-- This URL format is intentional: 0r-clothing appends dynamic suffixes.
-- By ending on a real file + query key, all appended variants still resolve.
Config.ImageBase = 'nui://0r-imagegenerator/images/placeholder.png?img='
Config.DefaultImageBase = 'nui://0r-imagegenerator/images/placeholder.png?img='

-- Enable only for troubleshooting callback flow.
Config.Debug = false
