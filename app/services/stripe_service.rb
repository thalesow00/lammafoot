class StripeService
  def initialize
    @stripe_secret_key = Rails.application.config.stripe[:secret_key]
    raise "Stripe secret key not configured" if @stripe_secret_key.blank?
  end

  def create_checkout_session(booking)
    Rails.logger.info "Creating Stripe session for booking #{booking.id}"
    
    session_params = {
      payment_method_types: [ "card" ],
      line_items: [ {
        price_data: {
          currency: "eur",
          product_data: {
            name: "Réservation - #{booking.stadium.name}",
            description: "Réservation du #{booking.start_date.strftime('%d/%m/%Y de %H:%M')} à #{booking.end_date.strftime('%H:%M')}"
          },
          unit_amount: (booking.total_price * 100).to_i
        },
        quantity: 1
      } ],
      mode: "payment",
      success_url: "http://localhost:3000/bookings/#{booking.id}/payment/success?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: "http://localhost:3000/bookings/#{booking.id}/payment/cancel",
      metadata: {
        booking_id: booking.id.to_s,
        user_id: booking.user.id.to_s
      }
    }
    
    Rails.logger.info "Stripe session params: #{session_params}"
    Stripe::Checkout::Session.create(session_params)
  end

  def retrieve_session(session_id)
    Stripe::Checkout::Session.retrieve(session_id)
  end

  def create_payment_intent(amount, currency = "eur", metadata = {})   

    
    Stripe::PaymentIntent.create({
      amount: (amount * 100).to_i,
      currency: currency,
      metadata: metadata
    })
  end
end
