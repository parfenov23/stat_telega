class ParseYt
  def self._search_from_topic(topic_id)
    max_date = Time.now.utc - 20.day
    current_time = Time.now.utc
    all_search = []
    count_times = 0
    while current_time > max_date
      p "Minus Hour: #{count_times += 1}"
      current_time = current_time - 1.hour
      after_time = (current_time - 1.hour).iso8601
      before_time = current_time.iso8601
      all_search += search_all_page(topic_id: topic_id, date_after: after_time, date_before: before_time)
      sleep(1)
    end
    all_search.uniq
  end

  def self.search_all_page(*args)
    params = args.first || {}
    first_page = search(params)
    count_search = first_page['pageInfo']['totalResults'] rescue 0
    p "Search Count: #{count_search}"
    next_page = first_page.nextPageToken
    all_items = first_page.items
    sleep(1)
    while next_page.present?
      current_search = search({page: next_page}.merge(params))
      next_page = current_search.nextPageToken
      all_items += current_search.items
      sleep(1)
    end
    all_items.uniq
  end

  def self.search(*args)
    parametrs = args.first || {}
    request("search", {
      publishedAfter: parametrs[:date_after],
      publishedBefore: parametrs[:date_before],
      part: "snippet",
      regionCode: "ru",
      type: "video",
      maxResults: 50,
      videoCategoryId: parametrs[:topic_id],
      pageToken: parametrs[:page],
      location: "55.7522200, 37.6155600",
      locationRadius: "1000km"
    }.compact)
  end

  def self.video_categories
    request("videoCategories", {part: "snippet", regionCode: "ru"})
  end

  def self.request(path, params={})
    params[:key] = "AIzaSyAa8yy0GdcGPHdtD083HiGGx_S0vMPScDM"
    current_url = "https://youtube.googleapis.com/youtube/v3/#{path}?#{params.compact.to_query}"
    p current_url
    uri = URI.parse(current_url)
    request = Net::HTTP::Get.new(uri)
    request["X-Origin"] = "https://explorer.apis.google.com"
    req_options = {
      use_ssl: uri.scheme == "https",
    }
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    JSON.parse(response.body, object_class: OpenStruct)
  end

  def self.all_topics(id=nil)
    topics = [
      {id: "/m/04rlf", title: "Music (parent topic)"}, 
      {id: "/m/02mscn", title: "Christian music"}, 
      {id: "/m/0ggq0m", title: "Classical music"}, 
      {id: "/m/01lyv", title: "Country"}, 
      {id: "/m/02lkt", title: "Electronic music"}, 
      {id: "/m/0glt670", title: "Hip hop music"}, 
      {id: "/m/05rwpb", title: "Independent music"}, 
      {id: "/m/03_d0", title: "Jazz"}, 
      {id: "/m/028sqc", title: "Music of Asia"},
      {id: "/m/0g293", title: "Music of Latin America"},
      {id: "/m/064t9", title: "Pop music"},
      {id: "/m/06cqb", title: "Reggae"},
      {id: "/m/06j6l", title: "Rhythm and blues"},
      {id: "/m/06by7", title: "Rock music"},
      {id: "/m/0gywn", title: "Soul music"},
      {id: "/m/0bzvm2", title: "Gaming (parent topic)"},
      {id: "/m/025zzc", title: "Action game"},
      {id: "/m/02ntfj", title: "Action-adventure game"},
      {id: "/m/0b1vjn", title: "Casual game"},
      {id: "/m/02hygl", title: "Music video game"},
      {id: "/m/04q1x3q", title: "Puzzle video game"},
      {id: "/m/01sjng", title: "Racing video game"},
      {id: "/m/0403l3g", title: "Role-playing video game"},
      {id: "/m/021bp2", title: "Simulation video game"},
      {id: "/m/022dc6", title: "Sports game"},
      {id: "/m/03hf_rm", title: "Strategy video game"},
      {id: "/m/06ntj", title: "Sports (parent topic)"},
      {id: "/m/0jm_", title: "American football"},
      {id: "/m/018jz", title: "Baseball"},
      {id: "/m/018w8", title: "Basketball"},
      {id: "/m/01cgz", title: "Boxing"},
      {id: "/m/09xp_", title: "Cricket"},
      {id: "/m/02vx4", title: "Football"},
      {id: "/m/037hz", title: "Golf"},
      {id: "/m/03tmr", title: "Ice hockey"},
      {id: "/m/01h7lh", title: "Mixed martial arts"},
      {id: "/m/0410tth", title: "Motorsport"},
      {id: "/m/07bs0", title: "Tennis"},
      {id: "/m/07_53", title: "Volleyball"},
      {id: "/m/02jjt", title: "Entertainment (parent topic)"},
      {id: "/m/09kqc", title: "Humor"},
      {id: "/m/02vxn", title: "Movies"},
      {id: "/m/05qjc", title: "Performing arts"},
      {id: "/m/066wd", title: "Professional wrestling"},
      {id: "/m/0f2f9", title: "TV shows"},
      {id: "/m/019_rr", title: "Lifestyle (parent topic)"},
      {id: "/m/032tl", title: "Fashion"},
      {id: "/m/027x7n", title: "Fitness"},
      {id: "/m/02wbm", title: "Food"},
      {id: "/m/03glg", title: "Hobby"},
      {id: "/m/068hy", title: "Pets"},
      {id: "/m/041xxh", title: "Physical attractiveness [Beauty]"},
      {id: "/m/07c1v", title: "Technology"},
      {id: "/m/07bxq", title: "Tourism"},
      {id: "/m/07yv9", title: "Vehicles"},
      {id: "/m/098wr", title: "Society (parent topic)"},
      {id: "/m/09s1f", title: "Business"},
      {id: "/m/0kt51", title: "Health"},
      {id: "/m/01h6rj", title: "Military"},
      {id: "/m/05qt0", title: "Politics"},
      {id: "/m/06bvp", title: "Religion"},
      {id: "/m/01k8wb", title: "Knowledge"}
    ]
    id.present? ? (topics.select{|topic| topic[:id] == id}.last || {})[:title] : topics
  end

  def self.all_categories
    [{id: "1", title: "Film & Animation"},
     {id: "2", title: "Autos & Vehicles"},
     {id: "10", title: "Music"},
     {id: "15", title: "Pets & Animals"},
     {id: "17", title: "Sports"},
     {id: "18", title: "Short Movies"},
     {id: "19", title: "Travel & Events"},
     {id: "20", title: "Gaming"},
     {id: "21", title: "Videoblogging"},
     {id: "22", title: "People & Blogs"},
     {id: "23", title: "Comedy"},
     {id: "24", title: "Entertainment"},
     {id: "25", title: "News & Politics"},
     {id: "26", title: "Howto & Style"},
     {id: "27", title: "Education"},
     {id: "28", title: "Science & Technology"},
     {id: "30", title: "Movies"},
     {id: "31", title: "Anime/Animation"},
     {id: "32", title: "Action/Adventure"},
     {id: "33", title: "Classics"},
     {id: "34", title: "Comedy"},
     {id: "35", title: "Documentary"},
     {id: "36", title: "Drama"},
     {id: "37", title: "Family"},
     {id: "38", title: "Foreign"},
     {id: "39", title: "Horror"},
     {id: "40", title: "Sci-Fi/Fantasy"},
     {id: "41", title: "Thriller"},
     {id: "42", title: "Shorts"},
     {id: "43", title: "Shows"},
     {id: "44", title: "Trailers"}]
  end
end