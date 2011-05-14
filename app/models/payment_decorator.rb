Payment.class_eval do
  # consume users store credit once the order has completed.
  fsm = self.state_machines[:state]
  fsm.after_transition :on => :complete, :do => :charge_money_on_complete
  fsm.after_transition :on => :void, :do => :delete_failed_order_credit
  fsm.after_transition :on => :started_processing, :do => :delete_failed_order_credit
  
  private
  # charging credit when order is ready
  def charge_money_on_complete
    begin
      constraint = YAML::load( CustomSetting.find_or_create_by_name("credit").value || "")
    rescue
      constraint = {}
    end
    return unless constraint[:auto_charge]
    
    credit = StoreCredit.find_or_create_by_reason(StoreCredit.payed_order_credit_name(order))
    constraint[:charge_percent] ||= 0
    constraint[:charge_percent] = constraint[:charge_percent]/100 if constraint[:charge_percent].to_f > 1
    credit.user = order.user
    credit.amount = credit.remaining_amount = order.total*constraint[:charge_percent]
    return credit.save
  end
  
  # removing credit if it is needed
  def delete_failed_order_credit
    credit = StoreCredit.find_by_reason(StoreCredit.payed_order_credit_name(order))
    credit.delete if credit
  end
    
end
