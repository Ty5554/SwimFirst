class BodyChartsController < ApplicationController
    before_action :authenticate_user!

    def index
      # 現在のユーザーのすべてのConditionデータを取得
      @q = current_user.bodies.ransack(params[:q])
      @all_q = ::Body.joins(user: :teams)
               .where(teams: { id: current_user.teams.ids })
               .distinct
               .ransack(params[:all_q])
      @bodies = @q.result(distinct: true)
      @all_bodies = @all_q.result(distinct: true)

      @athletes = current_user.teams.includes(:users).flat_map(&:users)

      fields = [ :recorded_on, :body_fat, :weight ]

      body_data = if current_user.role&.athlete?
        @bodies.pluck(*fields)
      elsif current_user.role&.coach?
        @all_bodies.pluck(*fields)
      else
        [] # 万が一ロールが想定外の場合のデフォルト
      end

      # グラフデータを生成
      @chart_data = {
        labels: body_data.map { |recorded_on, *_| recorded_on.strftime("%Y-%m-%d") },
        datasets: [
          {
            type: "line",
            label: "体脂肪率",
            data: body_data.map { |_, body_fat, *_| body_fat },
            borderColor: "#D00000",
            backgroundColor: "#D00000",
            yAxisID: "y1"
          },
          {
            type: "bar",
            label: "体重",
            data: body_data.map { |_, _, weight, *_| weight },
            borderColor: "#03045E",
            backgroundColor: "#03045E",
            yAxisID: "y2"
          }
        ]
      }
      # グラフのオプション設定
      @chart_options = {
        responsive: true,
        scales: {
          y1: {
            type: "linear",
            display: true,
            position: "left",
            min: 5,
            max: 20
          },
          y2: {
            type: "linear",
            display: true,
            position: "right",
            min: 40,
            max: 100
          }
        }
      }
    end
end
