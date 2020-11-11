total_number_discs = 13 --- Общее количество CD дисков / Total number of CDs

function InitDiscName(disc_data, disc_name) --- получаем предмет и имя диска
    local disc_num = tonumber(disc_name:sub(11)) --- получаем номер из имени - начиная с 11 символа в имени
    if not disc_num then
        return print('ERROR: wrong disc_name = ',disc_name)
    end

    local data = disc_data:getModData()
    data.disc_num = disc_num --- получаем таблицу нужного диска с нужным номером
end