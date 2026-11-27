categories = {
  earthquake: Category.find_or_create_by!(name: "耐震避難所", disaster_type: "震災"),
  flood: Category.find_or_create_by!(name: "給水拠点", disaster_type: "風水害"),
  landslide: Category.find_or_create_by!(name: "砂防インフラ", disaster_type: "土砂")
}

facilities_data = [
  {
    name: "第一小学校　耐震避難所",
    category: categories[:earthquake],
    description: "大きな地震が起きたときに地域のみんなが集まって安全に過ごせる耐震構造の小学校です。",
    address: "山口県美祢市◯◯町A-1",
    map_x: 22.0,
    map_y: 35.0
  },
  {
    name: "市民防災センター",
    category: categories[:earthquake],
    description: "非常食や毛布などの防災備蓄を保管し、地震のときの情報拠点になる施設です。",
    address: "山口県美祢市◯◯町B-2",
    map_x: 48.0,
    map_y: 28.0
  },
  {
    name: "中央給水拠点",
    category: categories[:flood],
    description: "台風や大雨で水道が止まったときに、飲み水を配るための大切な給水タンクがあります。",
    address: "山口県美祢市◯✕町C-3",
    map_x: 65.0,
    map_y: 52.0
  },
  {
    name: "排水ポンプ場",
    category: categories[:flood],
    description: "大雨で川の水が増えすぎたときに、まちに水があふれないようポンプで排水する施設です。",
    address: "山口県美祢市◯✕町D-4",
    map_x: 78.0,
    map_y: 68.0
  },
  {
    name: "北山　砂防ダム",
    category: categories[:landslide],
    description: "大雨で山から土砂が流れ出すのをせき止め、ふもとの家や道路を守る防災インフラです。",
    address: "山口県美祢市✕◯町E-5",
    map_x: 30.0,
    map_y: 75.0
  },
  {
    name: "高台コミュニティセンター",
    category: categories[:landslide],
    description: "土砂災害の危険があるときに、安全に避難できる高台にある地域の避難施設です。",
    address: "山口県美祢市✕◯町F-6",
    map_x: 55.0,
    map_y: 82.0
  }
]

facilities_data.each do |attrs|
  facility = Facility.find_or_initialize_by(name: attrs[:name])
  facility.assign_attributes(attrs.except(:name))
  facility.save!
end

puts "Seed完了：Category=#{Category.count}件、Facility=#{Facility.count}件"
