require 'pycall/import'
require 'json'
include PyCall::Import

pyfrom 'telethon', import: ['TelegramClient', 'sync', 'events', 'errors', 'types', 'functions', 'utils']
pyfrom 'telethon.tl.functions.channels', import: ['GetFullChannelRequest', 'JoinChannelRequest', 'GetChannelsRequest', 'GetParticipantsRequest']
pyfrom 'telethon.tl.functions.messages', import: ['ImportChatInviteRequest', "SendMessageRequest"]
pyfrom 'telethon.tl.types', import: ['InputPeerChannel', 'InputPeerUser', 'PeerChannel', 'PeerChat', 'InputChannel']
pyfrom 'telethon.sessions', import: ['SQLiteSession', 'StringSession']
pyfrom 'telethon.tl.functions.account', import: ['UpdateStatusRequest', 'UpdateUsernameRequest']

class ApiTelegram
  pyimport 'asyncio'
  CURR_LOOP = asyncio.new_event_loop()
  asyncio.set_event_loop(CURR_LOOP)

  # SESSION_ID = '6281223094134'

  attr_accessor :session_id, :telegram, :me_info, :config, :session_path, :curr_loop, :error

  # Инициализация и подключение к Телеграмм через телетон. Принимает ид название папки
  def initialize(session_id, curr_session_path=session_path)
    # pyimport 'asyncio'
    # @curr_loop = asyncio.new_event_loop()
    # asyncio.set_event_loop(CURR_LOOP)

    pyimport 'socks'
    @session_id = session_id
    @config = get_config(curr_session_path)
    @curr_loop = CURR_LOOP
    
    @telegram = TelegramClient.new(
      path_session(curr_session_path), 
      config["app_id"], 
      config["app_hash"], 
      proxy: current_proxy.proxy, 
      timeout: 10, 
      loop: @curr_loop, 
      device_model: config["device"], 
      app_version: config["app_version"],
      system_version: config["system_version"]
    )
    @error = {}
    @telegram.connect() # подключаем клиента
    set_online # говорим телеграмму что мы в сети
    @me_info = get_me # сохраняем информацию о себе
  rescue PyCall::PyError => e
    # @curr_loop.close()
    @telegram&.disconnect()
    @error = error_pocessing(e)
  end

  # Запрос информации о канале
  def get_channel_info(ch_id)
    result = telegram.call(GetFullChannelRequest.new(ch_id)).full_chat
    return {
      id: result.id,
      participants_count: result.participants_count,
      about: result.about
    }
  rescue PyCall::PyError => e
    return error_pocessing(e)
  end

  # Запрос информации об аккаунте сессии
  def get_me
    result = telegram.get_me()
    return {
      id: result.id,
      first_name: result.first_name,
      username: result.username
    }
  end

  # Получение tg id канала
  def get_channel_id(ch_name)
    return {id: telegram.get_peer_id(ch_name)}
  rescue PyCall::PyError => e
    return error_pocessing(e)
  end

  # вступает в канал и получает инфу он нем
  # ch_hash - B9PbR7OXOXU3YzUy
  # Не даст повторно вызвать метод раньше чем через 2 минуты
  def joinchat(ch_hash)
    result = telegram.call(ImportChatInviteRequest.new(ch_hash)).chats[0]
    
    return {
      id: result.id,
      participants_count: result.participants_count,
      about: result.about
    }
  rescue PyCall::PyError => e
    return error_pocessing(e)
  end

  # Установка что я появился в сети 
  # false - в онлайне | true - вышел из сети
  def set_online(status = false)
    telegram.call(UpdateStatusRequest.new(status))
  end

  # Отправка сообщений юзеру
  def send_message(user_id, message)
    result = telegram.call(SendMessageRequest.new(user_id, message))
    return result.id
  end

  def set_username
    nick_name = []
    5.times do
      nick_name << "#{[*?A..?Z].sample}#{[*?A..?Z].sample}"
    end
    nick_name = nick_name.join.downcase
    nick_name += "#{rand 1..9}#{rand 0..9}#{rand 0..9}"
    telegram.call(UpdateUsernameRequest.new(nick_name))
    return nick_name
  end

  def disconnect
    set_online(true) # выходим из сети
    # curr_loop.close() # закрываем луп
    telegram.disconnect() # закрываем соединение
  end

  def self.all_session_ids(curr_session_path)
    all_folders = Dir[curr_session_path + "/*"]
    all_folders.map{|folder| folder.gsub((curr_session_path + "/"), "").gsub((".session"), "")}
  end

  def self.sessions_warming_up(curr_session_path)
    all_users_id = []
    session_result = {}
    all_sessions = ApiTelegram.all_session_ids(curr_session_path)
    telegram_logger.info("Count session: #{all_sessions.count} ======")
    return if all_sessions.blank?
    c_s = 0
    all_sessions.each do |sid|
      telegram_logger.info("======== SID: #{sid} Count: #{c_s+=1} =========")
      session_result[sid] = 0
      begin
        api_telega = ApiTelegram.new(sid, curr_session_path)
        if api_telega.error.blank?
          telegram_logger.info("CONFIG: #{api_telega.config}")

          if api_telega.me_info[:username].nil?
            nick_name = api_telega.set_username
            telegram_logger.info("SET NICKNAME: #{nick_name}")
            curr_user = api_telega.get_channel_id(all_users_id.sample || "parfenov407")
            text = (0...50).map { ('a'..'z').to_a[rand(26)] }.join
            sleep(1)
            telegram_logger.info("SEND USER: #{curr_user}")
            msg = api_telega.send_message(curr_user[:id], text)
            telegram_logger.info("SendMessage User #{curr_user} Id: #{msg}")
          end

          (2).times do |i|
            ch_name = ApiTelegram.all_channel_names.sample
            telegram_logger.info("GET CHANNEL #{i} name: #{ch_name}:")
            channel_id = api_telega.get_channel_id(ch_name)
            if channel_id[:id].present?
              result = api_telega.get_channel_info(channel_id[:id])
              telegram_logger.info("Channel TgID: #{result[:id]} Channel Users: #{result[:participants_count]}")
              session_result[sid] += 1
              sleep((rand(2..6)))
            end
          end

          username = api_telega&.get_me[:username]
          all_users_id << username if !username.nil?
          api_telega&.disconnect

          # переносим в папку прогретые сессии
          FileUtils.move("#{curr_session_path}#{sid}", "#{Rails.root}/public/uploads/hot_session/#{sid}")
        else
          telegram_logger.info("SID: #{sid} | PROBLEM AUTH: #{api_telega.error[:error]} MSG: #{api_telega.error[:message]}")
          # api_telega&.curr_loop&.close()
          path = curr_session_path + sid
          # File.delete(path + ".session")
          # File.delete(path + ".json")
        end
      end
    end

    return session_result
  end

  def self.all_channel_names
    ["ecumenetest", "MTNM0", "Humor_13", "guides_python", "deti_turkey", "diya_china", "baraholka_bryanska", "free_traffs", "maximaffiliate", "dirtymemestm", "naukasrickom", "L_OS_1", "geonewsplanet", "wildberrieschtokupit", "votnosheniyakh", "zdorovtg_online", "Reddit", "Mersedes_Benzo", "Arhitector_TG", "sciencesfacts", 
      "Yoakemot", "Alchemy_of_Souls_Drama", "TMtokyorevengers", "ProspektDeriglazova", "to_spain", "fc_chelsea_fans", 
      "FootballFactly", "barcaone", "m_smeha", "yourhhope", "kyrgyzstan_muzyka", "mohit_agarwal_current_gk_Gs_Quiz", "novosti_nvrs", "UPSCEXAMTIPS", "Upsc_Current_Affairs_Gk_Quiz", 
      "barcelonav2", "PankovaHome", "rayskiy_r_a", "dostypnietrendy", "top_towar_wb", "gobizness", "fight_f1", "tamilhdstatus08", "couple_vids", 
      "modnayakontora", "kushnir_na_provode", "detvora_v_shkole", "kotarubooks", "penseeintellingente", "veterperemenpro", 
      "your_new_work", "franklincorderogrupo", "istoria_literatura", "diduknow0", "MapArchive", "biznesideirus", "tattootop1", "chat_relo_uk", "Doska_Okha", 
      "lokostchat", "dubaiii", "supercell_tg", "fixusphuket", "povarkz16", "wb_room", "TheMensHealth", "itsnotgoogle", "finaiz", 
      "tradinggroup69", "Hackedmod_apps", "MagnificatVzla", "FilmyMovies7", "crypto_pochatok", "cyberden_team", "enforit", "magicpinflipkartloots", "aplfootb", "deti_razvivashki", 
      "besplatnowb", "obyavalnr", "avtolpr", "msk_w_chat", "otakuntg", "Picnicok", "bzhb_tzhb", "pgstatus", "Sexxx_PornoHub_Videosss", "memape", "rabotavbishkeke01", "storytimeq", 
      "filminaanqliyskom2", "zxmoviess", "lrclubcomparts", "MaiDireVideo", "blogistorika", "samorazvitxxl", "jjjiig", "tamizhatorrent", "kazanmasanati", "ppc_analytics", "Geography_Gk_Quizs", 
      "WorldIsBrand", "CryptoMarketUpdates", "russiainlaw", "NYTBestsellers", "Indiskiy_kino_2021", "civilist_project", "popularrightnow", "terka4", "Ethio_tv", "RoleplayJualBeli", "asphalt_tg", 
      "EngineeringEbooks_Civil", "se_ducation", "novosti_politica_sport", "zxcavatarkiphonk", "la_patilla", "waltp38", "ultraPk", "vso_1", "time_kinos", "ZDfitsumkebede", "figmadev", "amazing_factss1", 
      "savepht", "mama_o_vazhnom", "ProRek_tg", "naebnet", "kasha_video", "Shows_Serials_Movies_Group", "VillainEditzOfficial", "AutismCentral", "BRANDS4HANDS", "Aakash_test_papers_2022", "koreyskiy_yazyk1", 
      "news_surat", "granitsa_ukrain_russia", "MyStakePromotions", "Sunrise_Coach_Noticias", "polly_reads", "GoEnglishRu", "gliautogoltelegram", "piter_coach", "mrasel_tr", "educraft_academy", "aogiriicons", 
      "ne_investor", "bereyerko", "embedded_system", "nemedic", "CScience1", "tipeedor", "mars_insiders", "iconsavatarki", "scladmedbooksmed2", "nedvighkamoscva", "legalized_musicx", "relictum_community", "silnoprosto_tg", 
      "alin_mood", "mamapapa_chat", "astro_1ogy", "salaty_zakusku", "cfc_zone", "medica1_book", "soxranifotky", "forarchi", "paidappspcsoftware", "bygirisimcichat", "fekerx", "crypto_dm", "elenatemirgalieva", "storiesininstagram", 
      "ethio_keldoch9", "tg_psyc", "nechegotvetit", "business_tipss", "Pronicatelnyy", "piar_chat717", "Anitik_edits", "konenkov_official", "entertainpsy", "visuality_one", "poznavatics", "whitevendee", "strroki", "hr_recr", "historyporn", 
      "kinoraite", "kinofilmovie", "Bali_russo", "apodcasts", "buhgalterrf_help", "lovefactoryoff", "defemme_community", "knigi_literaturaa", "nedvizpiter", "nedvizekat", "realtyszao", "realty_mitino", "investor_broker", "ekb_ndv", "technokratiya", 
      "CentralChanel", "ENDEMUDACHNN", "rabota_biznes_freelance", "emeyethiop", "BestIco", "european_f00tball", "hromosoma_tg", "airdrops_detectors", "rotang13", "VIP_CryptoBoss", "apul_study_zone", "freelead", "quiz_python", "NewsCroatia", "samara24onl", 
      "tvknew", "b_i_world", "stroykarff", "repatriant_arm", "Tvnetflix", "gethack2", "thebestaudiblenew", "Physicsonfingers", "depressivmemes", "SmartphoneKG", "psikhosoc", "Justdiyo", "chatobs", "MentalCrypton", "chem_1istry", "memes_thebest", "word_ms", 
      "mozhake", "successtech1", "en_teleg", "SAD_STATUS_TAMIL_HD", "faaact99", "ideafactory1", "seII_crypto", "news_unitedm", "Romantic_Love_Status_tamil", "storiforladies", "drift_craft_chat", "Crazybeats_4K", "sadsongser", "infosmondefrance", "ethiofreesporttvfreqinfogroup", 
      "sozday_semyu", "Monttecii", "udemy_ucretsiz", "kolbanenko_investor", "udemyfreekurs", "BillboordchartsTM", "loveknit", "stoppromokod", "vernemsvoe", "doctorintouch", "reddit0p", "fishechki", "robotics_channel", "reklama_birja1", "invest_for_week", "Kaisen_Jujutsu_Movie_0_Zero", 
      "storis_instagram_new", "just_go_dream", "DerhachiLIVE", "gdmorntg", "rusphoto33", "anekdot_humor_ink", "teawlmon", "test_test", "pro_sila", "redditlive", "javaquiz_mentor", "google_nws", "wine_fun_spb", "psychologys_diary", "appsforblind", "loot_dealsr", "gif_rechipts", "Hey_HR", 
      "being_student", "cryptmountains", "szaodeti", "ffttelega", "kazanmesta", "program_job", "Regionx_85", "filmes", "newautofzco", "Freshmanexamstores", "it_iz_tinder", "tutdagesttan", "gumidok_jungle", "nbsmnfckt", "psikhopofig", "barakholka_moscow13", "avtorynokbarnaul22rus", 
      "ukrainiansincanada", "AstroPhysicsBookss", "OPER_UZ", "movieongram", "vayzanue", "konasovatut", "ttatarlar", "chatszao", "barcelonazonas", "hitrosti_hozyaushki", "raznorabms", "podelkino", "Fix_x_Fox", "zamkadye_new", "astrocenter_h_n", "freeshipping", "umniyrebenok100", 
      "tattooxoo", "muzukarussia", "knigamedik", "baraxlo_belogorsk", "tovarka_chatblr", "CryptoPartyCrew", "obyavleniya_Dme", "obyavleniya_podolsk", "obyavleniya_vidnoe", "obyavleniya_butovo", "obyavleniya_SWAO", "obyavleniya_kommunarka", "brain_protect", "pets_mitino", "mitinodeti", 
      "rabota_mitino", "mitinoads", "szaoreklama", "mos_govor", "gibdd16", "sharqzz", "petszao", "rabotaszao", "beforeourtime", "kpcreation9", "serialyikinoshki", "pythonturboru", "Digitalntelligence", "freeizilife", "obmennik_msk", "it_mega_g", "breaking_spb", "chp_tula_region", 
      "bookstwowords", "dianajavsevamrasskazu", "na_fanere", "psiholog_seleznev", "don24tv", "ezogoroskop1", "woman_market1", "mi_mi_channel", "samarap", "olik_book", "speakengly", "bozinabooks", "pro_vizyal", "jONTeLkKXQE5OGFi123", "incident69Tver", "prm301", "Xoroshiy_vopros", 
      "gravity_falls_de", "psyxorazvitie", "marketplace_rossia", "objavlenija_sochi", "anapa_baraholka", "prokatisru", "prokatis_ru", "Kas6enko", "themakeup", "hornyimpact", "fuckfunnyanimals", "solemateru", "predprinimateli_biz", "kopiraitplus", "Sochi_v_seti", "vaylberis_skidki_besplatno", 
      "kinodive", "Energych", "artisticsketches", "TargetDefence102", "mimirusss", "ved_logistika_perevozki_import", "alldesigninteriors", "genshinfull20", "prohodvotme", "remont_moskvaa", "ucretsizapkuygulamalar", "PoznavaiKKa", "quotesofzday", "Crash_Course_in_Romance_k", "startupsbusinesss", 
      "BazaPromokod", "wildberiesojidanie", "speedsongzzs", "PyccKuu_KpacuBo", "medicinskie_lekcii", "cg_center", "mone_media", "historiacool", "It_isinteresting", "uvarovpavelUA", "yumor_i_tochka", "shrewd_psychologist", "chpkrasnodara", "divo_planeta", "mad7stray", "prestigemycars", "rostrudgovru", 
      "Dorogoj_redaktor_Teksty", "jaluzi_shtory", "promchat", "iconicjoom", "lofivibavatarki", "shein_set", "iq_turizm", "SishkaChannel", "kinobot1", "kazan_afisha", "PRODUCTORES_MUSICALES_GT", "telegatowarow", "TonyRobbinson", "Day_Plans_Group", "CertifiedTv", "Akansha_Karnwal", "AbujaLandsandProperties", 
      "CrazyWalls", "arsenalekappa", "restaurantmoscow", "antarvasnahindi_stories", "Nomus_serial1", "dalainside", "kitapkz1", "arden_YT", "rushistoryyy", "kazanmeal", "HyPeRHackingg", "chat_mitino", "piarxchatikk", "SubtletiesOfHealth", "decoder_pro", "SPB_STROi", "detmultfilm", "otzovik_telega", "marocina", 
      "roommarin", "Espnfc_news", "Housing_in_Moscow", "serbia_jilibili", "Ajaxfootballclubb", "mams_mitino", "rusfishingtravel", "DoskaNedvig", "soulmatejj", "KPcreation1", "would_of_status", "nordvpn0accounts0daily", "wantto_you", "telegain_new_vbot", "lazymarketer", "Housing_in_Sochi", 
      "BMWCLUB_RUSSIA", "ikigaibookjapanesesecret", "shutka4ch", "RichWhale_official", "prog_job", "romantic_tami_love_Status143", "rostovnadonu_afisha", "biz_investory", "motivational_status_0", "bienestarfinanciero22", "mamszao", "DoubleSweetThings", "BesT_MoTivatioN_M", "NewSongStatusVideos", 
      "Amigoss_del_ingles", "Motivation_Life_video", "peliculashoy", "Podslushano_novosti_Smr", "Hsoi1", "slavsvestnik", "PIYUSH_EDITS_FULL_SCREEN_STATUS", "korobochkaspichek", "shutka4chh", "rasty605", "Habe_shawi", "lenta75ru", "CNNNNNZ", "cooldesigns", "gusarovchat", "okolobaikala", 
      "a_Business_Proposal_k", "adbia_t", "ArchiveMichaelBurry", "news_blagaa", "farfond", "zazerkaliee", "piratecpa", "Be7strooong", "newsibirsk01", "free_psyho", "uinhurricane", "artilikeru", "zanimmath", "sproektirovan", "subaruservicensk", "Nature_status_song", "kazandoska", 
      "dizaininteriers", "ZLATANofficial", "recipechefs", "TAYANCHMOSCOWUZB", "rsdbonus", "video_tatar", "bukovel_travellers", "revdainforu", "stroitelkazan", "Mission_upsc_motivation", "course_free", "palominoansonyNFT", "chattte", "electrichki", "UbezicheRybaka", "montegram", 
      "tobiko_shop", "knigi_pedagog", "Coursat2020", "kkkmarya", "poputchik_kostroma_44", "nogti_rrr", "yessay23", "ZNAK_VSELENNOY", "helenmityhere", "nabchelonline", "rus_histori", "broken_couple", "net_workk", "mim_moscow", "smehyevina", "bizz2022pro", "pervyi_klass_zdorovo", 
      "cheltodayru", "Bevzenkocom", "wallpapers_box", "postavshiki_marketplace", "The_WeekndTW", "code_library", "manicyrniyMir", "kinogrand", "estatedesign", "tra7el", "Istanbul_shat", "Antalya_ruso", "turtsia_nedvizhimost", "belgiachat", "slovakiachat", "switzerlandchat", 
      "netherlandschat", "flymecheap", "ufa_shabashka", "psikhovzlom", "chanelgriboedov", "minifilm_tv", "oterranews", "photographmoscva", "Time_ment", "crimea24novosti", "SexualmenteHot"] 
    end

  private

  # Обработчик событий добавляется по мере неообходимости
  def error_pocessing(error)
    if error.message.include?("ValueError")
      return { error: "ValueError", message: error.message}
    end

    if error.message.include?("UsernameInvalidError")
      return { error: "UsernameInvalidError", message: error.message}
    end

    if error.message.include?("AuthKeyError") ||
      error.message.include?("AuthKeyUnregisteredError") ||
      error.message.include?("UserDeactivatedBanError") ||
      error.message.include?("AuthKeyDuplicatedError") ||
      error.message.include?("SessionRevokedError") ||
      error.message.include?("UserDeactivatedError") ||
      error.message.include?("unable to open database file")
      return { error: "Auth", message: error.message}
    end

    if error.message.include?("ChannelPrivateError")
      return { error: "ChannelPrivateError", message: error.message}
    end

    if error.message.include?("PeerFloodError")
      return { error: "PeerFloodError", message: error.message}
    end

    return error.message
  end

  def current_proxy
    proxy = socks.socksocket()
    current_ip = config["proxy_id"]
    if current_ip.nil?
      current_ip = all_proxy.sample
      result = JSON.parse(File.read(path_json))
      result["proxy"] = current_ip
      File.write(path_json, result.to_json)
    end
    proxy.set_proxy(proxy, socks.PROXY_TYPE_SOCKS5, current_ip, 8000)
    proxy
  end

  def all_proxy
    [
      "168.80.248.175",
      "168.80.253.91",
      "168.80.254.136",
      "168.80.253.86",
      "168.80.252.76",
      "168.80.252.91",
      "168.80.250.133",
      "45.95.150.89",
      "45.95.148.115",
      "45.95.148.37",
      "45.95.149.148",
      "45.95.150.177",
      "168.80.62.90",
      "87.247.146.4",
      "87.247.146.131",
      "45.10.248.174",
      "45.95.148.209",
      "91.198.208.187"
    ]
  end

  def get_config(curr_session_path)
    result = JSON.parse(File.read(path_json(curr_session_path)))
    result["proxy"] = "" if result["proxy"] == []
    proxy_ip = result["proxy"].to_s.length > 0 ? result["proxy"].split(":").first : nil
    
    {
      "app_id" => result["app_id"], 
      "app_hash" => result["app_hash"], 
      "device" => result["device"], 
      "app_version" => result["app_version"],
      "proxy_id" => proxy_ip,
      "system_version" => result["system_version"] || result["sdk"]
    }
  end

  def path_json(curr_session_path)
    curr_session_path + session_id + "/" + session_id + ".json"
  end

  def path_session(curr_session_path)
    curr_session_path + session_id + "/" + session_id + ".session"
  end

  def self.session_path
    "#{Rails.root}/public/uploads/hot_session/"
  end

  def self.telegram_logger #telegram_logger.info
    @payment_logger ||= Logger.new("#{Rails.root}/log/telegram-hot.log")
  end

end
