module ApplicationHelper
  def default_meta_tags
    {
      site: "SwimFirst",
      title: "SwimFirst | 水泳選手のコンディション管理アプリ",
      reverse: true,
      charset: "utf-8",
      description: "SwimFirstは、水泳選手やコーチ向けのコンディション管理アプリです。データを一元管理し、水泳指導理論に基づいた運動強度の設定をサポートします。AIアシスタントがトレーニング後のフィードバックを提供し、選手のパフォーマンス向上を支援します。",
      keywords: "水泳,コンディション,トレーニング,アスリート,パフォーマンス向上,スポーツ科学,AIアシスタント,水泳トレーニング",
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
        local: "ja_JP"
      }
    }
  end
end
