fx_version 'cerulean'
game 'gta5'

author 'QUADRIA'
description 'NMNOTELTINT'

-- [AUDIT AUD-002] this_is_a_map mantiene carga de ymaps/ytyps del stream/
this_is_a_map 'yes'

lua54 'yes'

-- [AUDIT AUD-002] data_file y files de qua_nmotel_timecycle.xml eliminados (archivo inexistente)
-- Si se recupera el XML original, descomentar:
-- data_file 'TIMECYCLEMOD_FILE' 'qua_nmotel_timecycle.xml'
-- files { 'qua_nmotel_timecycle.xml' }

client_script {
    "qua_nmotel_corridor_ipls.lua",
}
