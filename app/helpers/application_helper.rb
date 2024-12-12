module ApplicationHelper
  def default_meta_tags
    {
      site: "SwimFirst",
      title: "SwimFirst",
      reverse: true,
      charset: "utf-8",
      description: "水泳選手のためのコンディション管理サービス",
      keywords: "水泳,コンディション,トレーニング",
      canonical: request.original_url,
      separator: "|",
      icon: [
        { href: image_url("swimerLogo.png") },
        { href: image_url("ogp.png"), rel: "apple-touch-icon", sizes: "90x90", type: "image/png" }
      ],
      og: {
        site_name: :site,
        title: :title,
        description: :description,
        type: "website",
        url: request.original_url,
        image: image_url("ogp.png"),
        local: "ja-JP"
      }
    }
  end
end
