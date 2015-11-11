class CombineItemsInCart < ActiveRecord::Migration
  def change
  end

  def up
# Sostituite più esemplari di un singolo prodotto nel carrello con un unico articolo
    Cart.all.each do |cart|
# Contate il numero di ciascun prodotto nel carrello
      sums = cart.line_items.group(:product_id).sum(:quantity)
      sums.each do |product_id, quantity|
        if quantity > 1
# Eliminate i singoli articoli
          cart.line_items.where(product_id: product_id).delete_all
# Sostituite con un unico articolo
          item = cart.line_items.build(product_id: product_id)
          item.quantity = quantity
          item.save!
        end

      end
    end
  end

  def down
# Suddividete gli articoli con quantità maggiore di 1 in più righe d'ordine
    LineItem.where("quantity>1").each do |line_item|
# Aggiungete singoli articoli
      line_item.quantity.times do
        LineItem.create cart_id: line_item.cart_id, product_id: line_item.product_id, quantity: 1
      end
# Rimuovete l'articolo originale
      line_item.destroy
    end
  end
end