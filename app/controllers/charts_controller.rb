class ChartsController < ApplicationController
  before_action :authenticate_user!

  def index
    # 現在のユーザーのすべてのConditionデータを取得
    @q = current_user.conditions.ransack(params[:q])
    @conditions = @q.result(distinct: true)

    # グラフデータを生成
    @chart1_data = {
      labels: @conditions.pluck(:recorded_on).map { |date| date.strftime("%Y-%m-%d") },
      datasets: [
        {
          type: "line",
          label: "肉体的疲労度",
          data: @conditions.pluck(:fatigue_level),
          borderColor: "#FF7B00",
          backgroundColor: "#FF7B00",
          yAxisID: "y"
        },
        {
          type: "line",
          label: "精神的疲労度",
          data: @conditions.pluck(:mental_state),
          borderColor: "#007F5F",
          backgroundColor: "#007F5F",
          yAxisID: "y"
        }
      ]
    }
    # グラフのオプション設定
    @chart1_options = {
      responsive: true,
      scales: {
        y: {
          type: "linear",
          display: true,
          position: "left",
          min: 0,
          max: 100
        }
      }
    }

    @chart2_data = {
      labels: @conditions.pluck(:recorded_on).map { |date| date.strftime("%Y-%m-%d") },
      datasets: [
        {
          type: "line",
          label: "体温",
          data: @conditions.pluck(:body_temperature),
          borderColor: "#D00000",
          backgroundColor: "#D00000",
          yAxisID: "y"
        },
        {
          type: "line",
          label: "睡眠時間",
          data: @conditions.pluck(:sleep_hours),
          borderColor: "#03045E",
          backgroundColor: "#03045E",
          yAxisID: "y1"
        }
      ]
    }
    # グラフのオプション設定
    @chart2_options = {
      responsive: true,
      scales: {
        y: {
          type: "linear",
          display: true,
          position: "left",
          min: 30,
          max: 40
        },
        y1: {
          type: "linear",
          display: true,
          position: "right",
          min: 0,
          max: 10
        }
      }
    }
  end
end
