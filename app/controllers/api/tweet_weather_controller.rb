class Api::TweetWeatherController < ApplicationController

	def post_tweet
		city_id = permit_params[:id].to_s
		current_temperature = OpenWeatherMap.get_current_temperature(city_id, ENV["API_KEY_OPENWEATHERMAP"])

		unless current_temperature['ok']
			render json: {error: current_temperature['error_message']}, status: current_temperature['code']
			return
		end
		
		forecast_temperature = OpenWeatherMap.get_forecast_temperature(city_id, ENV["API_KEY_OPENWEATHERMAP"])
		
		unless forecast_temperature['ok']
			render json: {error: forecast_temperature['error_message']}, status: forecast_temperature['code']
			return
		end 

		data_referencia = (Date.current + 1).to_s
		hash_medias = {}

		for i in 1..5 do
			forecast_date = forecast_temperature['body']['list'].select{|s| s['dt_txt'].start_with?(data_referencia) }
			soma = forecast_date.sum{|s| s['main']['temp']}
			media = (soma / forecast_date.count).round(0)
			hash_medias[data_referencia] = media
			data_referencia = (data_referencia.to_date + 1).to_s
		end

		get_twitter.update("#{current_temperature['body']['main']['temp'].round(0)}ºC e #{current_temperature['body']['weather'][0]['description']} em #{current_temperature['body']['name']} em #{Date.current.strftime('%d/%m')}. Média para os próximos dias: " + hash_medias.map{|k, v| "#{v}ºC em #{k.to_date.strftime('%d/%m')}" }.join(', ') + '.')

		render status: 201
	end

	private
	
	def permit_params
		params.require(:tweet_weather).permit(:id)
	end		
end		
