class StudentsController < ApplicationController
  def new
    @student = Student.new
  end

  def create
    @student = Student.new(student_params)
    if @student.save
      redirect_to @student
    else
      render :new
    end
  end

  def show
    @student = Student.find(params[:id])
    @installments = @student.installments
  end

  def pay_installment
    @student = Student.find(params[:id])
    @installment = @student.installments.find(params[:installment_id])

    amount_paid = params[:amount].to_f
    if amount_paid > @installment.due
      excess_amount = amount_paid - @installment.due
      @installment.update(paid: amount_paid, due: 0, status: 'paid')
      adjust_next_installments(@student, excess_amount)
    elsif amount_paid < @installment.due
      remaining_amount = @installment.due - amount_paid
      handle_less_payment(@installment, amount_paid, remaining_amount, params[:action_choice])
    else
      @installment.update(paid: amount_paid, due: 0, status: 'paid')
    end

    redirect_to @student
  end

  private

  def student_params
    params.require(:student).permit(:name, :total_fee, :number_of_installments)
  end

  def adjust_next_installments(student, excess_amount)
    student.installments.where(status: 'pending').each do |installment|
      if excess_amount > 0
        if excess_amount >= installment.due
          excess_amount -= installment.due
          installment.update(paid: installment.amount, due: 0, status: 'paid')
        else
          installment.update(due: installment.due - excess_amount)
          excess_amount = 0
        end
      end
    end
  end

  def handle_less_payment(installment, amount_paid, remaining_amount, action_choice)

    next_installment = installment.student.installments.where(status: 'pending')
    if next_installment.count == 1 && remaining_amount > 0 && action_choice == 'next_installment'
      installment.student.installments.create(amount: remaining_amount, paid: 0, due: remaining_amount, status: 'pending')
      installment.update(paid: amount_paid, status: 'paid', due: 0)
      return
    end
    installment.update(paid: amount_paid, status: 'paid', due: 0)
    if action_choice == 'next_installment'
      next_installment = installment.student.installments.where(status: 'pending').first
      if next_installment
        next_installment.update(due: next_installment.due + remaining_amount)
      end
    elsif action_choice == 'new_installment'
      installment.student.installments.create(amount: remaining_amount, paid: 0, due: remaining_amount, status: 'pending')
    end
  end
end
