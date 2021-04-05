module ApplicationHelper
  def all_categories
    [
      {id: "1", title: "Бизнес и финансы"}, 
      {id: "2", title: "Интернет, маркетинг"}, 
      {id: "3", title: "Женский раздел"}, 
      {id: "4", title: "Авторские блоги"}, 
      {id: "5", title: "Мотивация, саморазвитие"}, 
      {id: "6", title: "Культура, образование, искусство"}, 
      {id: "7", title: "Удалёнка и фриланс"}, 
      {id: "8", title: "18+"}, 
      {id: "9", title: "Криптовалюты"}, 
      {id: "10", title: "Отдых и развлечения"}, 
      {id: "11", title: "ИТ"}, 
      {id: "12", title: "Мужской раздел"}, 
      {id: "13", title: "Работа"}, 
      {id: "14", title: "Медицина и здоровье"}, 
      {id: "15", title: "Товары и услуги"}, 
      {id: "16", title: "Авто и мото"}, 
      {id: "17", title: "Каталоги каналов и ботов"}, 
      {id: "18", title: "Спорт"}, 
      {id: "19", title: "Популярные"}, 
      {id: "20", title: "Кулинария"}, 
      {id: "21", title: "Туризм и путешествия"}, 
      {id: "22", title: "СМИ"}, 
      {id: "23", title: "Кино"}, 
      {id: "24", title: "Иностранные языки"}, 
      {id: "25", title: "Наука и технологии"}, 
      {id: "26", title: "Игры"}, 
      {id: "27", title: "Музыка"}, 
      {id: "28", title: "Дизайн и декор"}, 
      {id: "29", title: "Узбекские каналы"}, 
      {id: "30", title: "Офис"}, 
      {id: "31", title: "Юриспруденция"}, 
      {id: "32", title: "Недвижимость"}, 
      {id: "33", title: "Другое"}, 
      {id: "34", title: "Красота и здоровье"}, 
      {id: "35", title: "Дом и уют"}, 
      {id: "36", title: "Мода и стиль"}, 
      {id: "37", title: "Региональные"}, 
      {id: "38", title: "Родители и дети"}]
  end

  def find_category(id)
    find_category = all_categories.select{|category| category[:id] == id.to_s}.last
    find_category.present? ? find_category[:title] : "-"
  end
end
