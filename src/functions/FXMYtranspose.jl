# f(x,y)=x-y'

FXMYtranspose(x::Float64,y::Float64)=Fxmy(x,y)
FXMYtranspose(x::Float64,y)=Fxmy(x,y')
FXMYtranspose(x,y::Float64)=Fxmy(x,y)
FXMYtranspose(x,y)=Fxmy(x,y')
FXMYtranspose_inplace(value,auxvalue,x,y)=Fxmy_inplace(value,auxvalue,x,y')

function DXMYtranspose(derivativeIDX,f_c,faux_c,grad_c,grad_n,x::Array,y::Array)
    if derivativeIDX==1
        if size(x)==(1,1)
            axpy!(1.0,[sum(grad_c)],grad_n)
        else
            axpy!(1.0,grad_c,grad_n)
        end
    elseif derivativeIDX==2
        if size(y)==(1,1)
            axpy!(-1.0,[sum(grad_c)],grad_n)
        else
            axpy!(-1.0,grad_c',grad_n)
        end
    end
end


if PROC=="GPU"

    function FXMYtranspose_inplace(value::CudaArray,auxvalue,x::CudaArray,y::CudaArray)
        if size(x)==(1,1)
            gfill!(value,x);
            CUBLAS.geam!('N','T',1.0,value,-1.0,y,value)
        elseif size(y)==(1,1)
            gfill!(value,y)
            CUBLAS.geam!('N','N',1.0,x,-1.0,value,value)
        else
            CUBLAS.geam!('N','T',1.0,x,-1.0,y,value)
        end
    end

    function DXMYtranspose(derivativeIDX,f_c,faux_c,grad_c,grad_n,x::CudaArray,y::CudaArray)
        if derivativeIDX==1
            if size(x)==(1,1)
                axpy!(1.0,sum(grad_c),grad_n)
            else
                tmp=CudaArray(Float64,size(grad_c))
                CUBLAS.geam!('T','N',1.0,grad_c,0.0,tmp,tmp) # tmp=grad_c'
                axpy!(1.0,tmp,grad_n); free(tmp)
            end
        elseif derivativeIDX==2
            if size(y)==(1,1)
                axpy!(-1.0,sum(grad_c),grad_n)
            else
                tmp=CudaArray(Float64,size(grad_c))
                CUBLAS.geam!('T','N',1.0,grad_c,0.0,tmp,tmp) # tmp=grad_c'
                axpy!(-1.0,tmp,grad_n); free(tmp)
            end
        end
    end

end

Derivative[FXMYtranspose]=DXMYtranspose
Inplace[FXMYtranspose]=FXMYtranspose_inplace

export FXMYtranspose


