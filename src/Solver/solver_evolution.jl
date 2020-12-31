"""
Evolution

"""
function evolve!(
    KS::SolverSet,
    ctr::T1,
    face::T2,
    dt;
    mode = Symbol(KS.set.flux)::Symbol,
    bc = :fix::Symbol,
    isPlasma = false::Bool,
    isMHD = false::Bool,
) where {T1<:AbstractArray{ControlVolume1D,1},T2<:AbstractArray{Interface1D,1}}

    if firstindex(KS.pSpace.x) < 1
        idx0 = 1
        idx1 = KS.pSpace.nx + 1
    else
        idx0 = 2
        idx1 = KS.pSpace.nx
    end

    if mode == :gks

        @inbounds Threads.@threads for i = idx0:idx1
            flux_gks!(
                face[i].fw,
                ctr[i-1].w .+ 0.5 .* ctr[i-1].dx .* ctr[i-1].sw,
                ctr[i].w .- 0.5 .* ctr[i].dx .* ctr[i].sw,
                KS.gas.γ,
                KS.gas.K,
                KS.gas.μᵣ,
                KS.gas.ω,
                dt,
                0.5 * ctr[i-1].dx,
                0.5 * ctr[i].dx,
                ctr[i-1].sf,
                ctr[i].sf,
            )
        end

    elseif mode == :roe

        @inbounds Threads.@threads for i = idx0:idx1
            flux_roe!(
                face[i].fw,
                ctr[i-1].w .+ 0.5 .* ctr[i-1].dx .* ctr[i-1].sw,
                ctr[i].w .- 0.5 .* ctr[i].dx .* ctr[i].sw,
                KS.gas.γ,
                dt,
            )
        end

    end

end

function evolve!(
    KS::SolverSet,
    ctr::T1,
    face::T2,
    dt;
    mode = Symbol(KS.set.flux)::Symbol,
    bc = :fix::Symbol,
) where {T1<:AbstractArray{ControlVolume1D1F,1},T2<:AbstractArray{Interface1D1F,1}}

    if firstindex(KS.pSpace.x) < 1
        idx0 = 1
        idx1 = KS.pSpace.nx + 1
    else
        idx0 = 2
        idx1 = KS.pSpace.nx
    end

    if KS.set.space[5:end] == "1v"

        if mode == :kfvs
            @inbounds Threads.@threads for i = idx0:idx1
                flux_kfvs!(
                    face[i].fw,
                    face[i].ff,
                    ctr[i-1].f .+ 0.5 .* ctr[i-1].dx .* ctr[i-1].sf,
                    ctr[i].f .- 0.5 .* ctr[i].dx .* ctr[i].sf,
                    KS.vSpace.u,
                    KS.vSpace.weights,
                    dt,
                    ctr[i-1].sf,
                    ctr[i].sf,
                )
            end
        elseif mode == :kcu
            @inbounds Threads.@threads for i = idx0:idx1
                flux_kcu!(
                    face[i].fw,
                    face[i].ff,
                    ctr[i-1].w .+ 0.5 .* ctr[i-1].dx .* ctr[i-1].sw,
                    ctr[i-1].f .+ 0.5 .* ctr[i-1].dx .* ctr[i-1].sf,
                    ctr[i].w .- 0.5 .* ctr[i].dx .* ctr[i].sw,
                    ctr[i].f .- 0.5 .* ctr[i].dx .* ctr[i].sf,
                    KS.vSpace.u,
                    KS.vSpace.weights,
                    KS.gas.K,
                    KS.gas.γ,
                    KS.gas.μᵣ,
                    KS.gas.ω,
                    KS.gas.Pr,
                    dt,
                )
            end
        end

    elseif KS.set.space[5:end] == "3v"

        if mode == :kfvs
            @inbounds Threads.@threads for i = idx0:idx1
                flux_kfvs!(
                    face[i].fw,
                    face[i].ff,
                    ctr[i-1].f .+ 0.5 .* ctr[i-1].dx .* ctr[i-1].sf,
                    ctr[i].f .- 0.5 .* ctr[i].dx .* ctr[i].sf,
                    KS.vSpace.u,
                    KS.vSpace.v,
                    KS.vSpace.w,
                    KS.vSpace.weights,
                    dt,
                    ctr[i-1].sf,
                    ctr[i].sf,
                )
            end
        elseif mode == :kcu
        end

    end

end

function evolve!(
    KS::SolverSet,
    ctr::T1,
    face::T2,
    dt;
    mode = Symbol(KS.set.flux)::Symbol,
    bc = :fix::Symbol,
) where {T1<:AbstractArray{ControlVolume1D2F,1},T2<:AbstractArray{Interface1D2F,1}}

    if firstindex(KS.pSpace.x) < 1
        idx0 = 1
        idx1 = KS.pSpace.nx + 1
    else
        idx0 = 2
        idx1 = KS.pSpace.nx
    end

    if mode == :kfvs

        @inbounds Threads.@threads for i = idx0:idx1
            flux_kfvs!(
                face[i].fw,
                face[i].fh,
                face[i].fb,
                ctr[i-1].h .+ 0.5 .* ctr[i-1].dx .* ctr[i-1].sh,
                ctr[i-1].b .+ 0.5 .* ctr[i-1].dx .* ctr[i-1].sb,
                ctr[i].h .- 0.5 .* ctr[i].dx .* ctr[i].sh,
                ctr[i].b .- 0.5 .* ctr[i].dx .* ctr[i].sb,
                KS.vSpace.u,
                KS.vSpace.weights,
                dt,
                ctr[i-1].sh,
                ctr[i-1].sb,
                ctr[i].sh,
                ctr[i].sb,
            )
        end

    elseif mode == :kcu

        @inbounds Threads.@threads for i = idx0:idx1
            flux_kcu!(
                face[i].fw,
                face[i].fh,
                face[i].fb,
                ctr[i-1].w .+ 0.5 .* ctr[i-1].dx .* ctr[i-1].sw,
                ctr[i-1].h .+ 0.5 .* ctr[i-1].dx .* ctr[i-1].sh,
                ctr[i-1].b .+ 0.5 .* ctr[i-1].dx .* ctr[i-1].sb,
                ctr[i].w .- 0.5 .* ctr[i].dx .* ctr[i].sw,
                ctr[i].h .- 0.5 .* ctr[i].dx .* ctr[i].sh,
                ctr[i].b .- 0.5 .* ctr[i].dx .* ctr[i].sb,
                KS.vSpace.u,
                KS.vSpace.weights,
                KS.gas.K,
                KS.gas.γ,
                KS.gas.μᵣ,
                KS.gas.ω,
                KS.gas.Pr,
                dt,
            )
        end

    end

    if bc == :maxwell
        flux_boundary_maxwell!(
            face[1].fw,
            face[1].fh,
            face[1].fb,
            KS.ib.bcL,
            ctr[1].h,
            ctr[1].b,
            KS.vSpace.u,
            KS.vSpace.weights,
            KS.gas.inK,
            dt,
            1,
        )
        flux_boundary_maxwell!(
            face[KS.pSpace.nx+1].fw,
            face[KS.pSpace.nx+1].fh,
            face[KS.pSpace.nx+1].fb,
            KS.ib.bcR,
            ctr[KS.pSpace.nx].h,
            ctr[KS.pSpace.nx].b,
            KS.vSpace.u,
            KS.vSpace.weights,
            KS.gas.inK,
            dt,
            -1,
        )
    end

end

function evolve!(
    KS::SolverSet,
    ctr::T1,
    face::T2,
    dt;
    mode = Symbol(KS.set.flux)::Symbol,
    bc = :fix::Symbol,
    isPlasma = false::Bool,
    isMHD = false::Bool,
) where {T1<:AbstractArray{ControlVolume1D4F,1},T2<:AbstractArray{Interface1D4F,1}}

    if firstindex(KS.pSpace.x) < 1
        idx0 = 1
        idx1 = KS.pSpace.nx + 1
    else
        idx0 = 2
        idx1 = KS.pSpace.nx
    end

    if mode == :kcu
        @inbounds Threads.@threads for i = idx0:idx1
            flux_kcu!(
                face[i].fw,
                face[i].fh0,
                face[i].fh1,
                face[i].fh2,
                face[i].fh3,
                ctr[i-1].w .+ 0.5 .* ctr[i-1].dx .* ctr[i-1].sw,
                ctr[i-1].h0 .+ 0.5 .* ctr[i-1].dx .* ctr[i-1].sh0,
                ctr[i-1].h1 .+ 0.5 .* ctr[i-1].dx .* ctr[i-1].sh1,
                ctr[i-1].h2 .+ 0.5 .* ctr[i-1].dx .* ctr[i-1].sh2,
                ctr[i-1].h3 .+ 0.5 .* ctr[i-1].dx .* ctr[i-1].sh3,
                ctr[i].w .- 0.5 .* ctr[i].dx .* ctr[i].sw,
                ctr[i].h0 .- 0.5 .* ctr[i].dx .* ctr[i].sh0,
                ctr[i].h1 .- 0.5 .* ctr[i].dx .* ctr[i].sh1,
                ctr[i].h2 .- 0.5 .* ctr[i].dx .* ctr[i].sh2,
                ctr[i].h3 .- 0.5 .* ctr[i].dx .* ctr[i].sh3,
                KS.vSpace.u,
                KS.vSpace.weights,
                KS.gas.K,
                KS.gas.γ,
                KS.gas.mi,
                KS.gas.ni,
                KS.gas.me,
                KS.gas.ne,
                KS.gas.Kn[1],
                dt,
                isMHD,
            )
        end
    elseif mode == :kfvs
        @inbounds Threads.@threads for i = idx0:idx1
            flux_kfvs!(
                face[i].fw,
                face[i].fh0,
                face[i].fh1,
                face[i].fh2,
                face[i].fh3,
                ctr[i-1].h0 .+ 0.5 .* ctr[i-1].dx .* ctr[i-1].sh0,
                ctr[i-1].h1 .+ 0.5 .* ctr[i-1].dx .* ctr[i-1].sh1,
                ctr[i-1].h2 .+ 0.5 .* ctr[i-1].dx .* ctr[i-1].sh2,
                ctr[i-1].h3 .+ 0.5 .* ctr[i-1].dx .* ctr[i-1].sh3,
                ctr[i].h0 .- 0.5 .* ctr[i].dx .* ctr[i].sh0,
                ctr[i].h1 .- 0.5 .* ctr[i].dx .* ctr[i].sh1,
                ctr[i].h2 .- 0.5 .* ctr[i].dx .* ctr[i].sh2,
                ctr[i].h3 .- 0.5 .* ctr[i].dx .* ctr[i].sh3,
                KS.vSpace.u,
                KS.vSpace.weights,
                dt,
                ctr[i-1].sh0,
                ctr[i-1].sh1,
                ctr[i-1].sh2,
                ctr[i-1].sh3,
                ctr[i].sh0,
                ctr[i].sh1,
                ctr[i].sh2,
                ctr[i].sh3,
            )
        end
    end

    if isPlasma
        @inbounds Threads.@threads for i = idx0:idx1
            flux_em!(
                face[i].femL,
                face[i].femR,
                ctr[i-2].E,
                ctr[i-2].B,
                ctr[i-1].E,
                ctr[i-1].B,
                ctr[i].E,
                ctr[i].B,
                ctr[i+1].E,
                ctr[i+1].B,
                ctr[i-1].ϕ,
                ctr[i].ϕ,
                ctr[i-1].ψ,
                ctr[i].ψ,
                ctr[i-1].dx,
                ctr[i].dx,
                KS.gas.Ap,
                KS.gas.An,
                KS.gas.D,
                KS.gas.sol,
                KS.gas.χ,
                KS.gas.ν,
                dt,
            )
        end
    end

end

function evolve!(
    KS::SolverSet,
    ctr::T1,
    face::T2,
    dt;
    mode = Symbol(KS.set.flux)::Symbol,
    bc = :fix::Symbol,
    isPlasma = false::Bool,
    isMHD = false::Bool,
) where {T1<:AbstractArray{ControlVolume1D3F,1},T2<:AbstractArray{Interface1D3F,1}}

    if firstindex(KS.pSpace.x) < 1
        idx0 = 1
        idx1 = KS.pSpace.nx + 1
    else
        idx0 = 2
        idx1 = KS.pSpace.nx
    end

    if mode == :kcu
        @inbounds Threads.@threads for i = idx0:idx1
            flux_kcu!(
                face[i].fw,
                face[i].fh0,
                face[i].fh1,
                face[i].fh2,
                ctr[i-1].w .+ 0.5 .* ctr[i-1].dx .* ctr[i-1].sw,
                ctr[i-1].h0 .+ 0.5 .* ctr[i-1].dx .* ctr[i-1].sh0,
                ctr[i-1].h1 .+ 0.5 .* ctr[i-1].dx .* ctr[i-1].sh1,
                ctr[i-1].h2 .+ 0.5 .* ctr[i-1].dx .* ctr[i-1].sh2,
                ctr[i].w .- 0.5 .* ctr[i].dx .* ctr[i].sw,
                ctr[i].h0 .- 0.5 .* ctr[i].dx .* ctr[i].sh0,
                ctr[i].h1 .- 0.5 .* ctr[i].dx .* ctr[i].sh1,
                ctr[i].h2 .- 0.5 .* ctr[i].dx .* ctr[i].sh2,
                KS.vSpace.u,
                KS.vSpace.v,
                KS.vSpace.weights,
                KS.gas.K,
                KS.gas.γ,
                KS.gas.mi,
                KS.gas.ni,
                KS.gas.me,
                KS.gas.ne,
                KS.gas.Kn[1],
                dt,
                1.0,
                isMHD,
            )
        end
    elseif mode == :kfvs
        @inbounds Threads.@threads for i = idx0:idx1
            flux_kfvs!(
                face[i].fw,
                face[i].fh0,
                face[i].fh1,
                face[i].fh2,
                ctr[i-1].h0 .+ 0.5 .* ctr[i-1].dx .* ctr[i-1].sh0,
                ctr[i-1].h1 .+ 0.5 .* ctr[i-1].dx .* ctr[i-1].sh1,
                ctr[i-1].h2 .+ 0.5 .* ctr[i-1].dx .* ctr[i-1].sh2,
                ctr[i].h0 .- 0.5 .* ctr[i].dx .* ctr[i].sh0,
                ctr[i].h1 .- 0.5 .* ctr[i].dx .* ctr[i].sh1,
                ctr[i].h2 .- 0.5 .* ctr[i].dx .* ctr[i].sh2,
                KS.vSpace.u,
                KS.vSpace.v,
                KS.vSpace.weights,
                dt,
                1.0,
                ctr[i-1].sh0,
                ctr[i-1].sh1,
                ctr[i-1].sh2,
                ctr[i].sh0,
                ctr[i].sh1,
                ctr[i].sh2,
            )
        end
    elseif mode == :ugks
        @inbounds Threads.@threads for i = idx0:idx1
            flux_ugks!(
                face[i].fw,
                face[i].fh0,
                face[i].fh1,
                face[i].fh2,
                ctr[i-1].w .+ 0.5 .* ctr[i-1].dx .* ctr[i-1].sw,
                ctr[i-1].h0 .+ 0.5 .* ctr[i-1].dx .* ctr[i-1].sh0,
                ctr[i-1].h1 .+ 0.5 .* ctr[i-1].dx .* ctr[i-1].sh1,
                ctr[i-1].h2 .+ 0.5 .* ctr[i-1].dx .* ctr[i-1].sh2,
                ctr[i].w .- 0.5 .* ctr[i].dx .* ctr[i].sw,
                ctr[i].h0 .- 0.5 .* ctr[i].dx .* ctr[i].sh0,
                ctr[i].h1 .- 0.5 .* ctr[i].dx .* ctr[i].sh1,
                ctr[i].h2 .- 0.5 .* ctr[i].dx .* ctr[i].sh2,
                KS.vSpace.u,
                KS.vSpace.v,
                KS.vSpace.weights,
                KS.gas.K,
                KS.gas.γ,
                KS.gas.mi,
                KS.gas.ni,
                KS.gas.me,
                KS.gas.ne,
                KS.gas.Kn[1],
                dt,
                0.5 * ctr[i-1].dx,
                0.5 * ctr[i].dx,
                1.0,
                ctr[i-1].sh0,
                ctr[i-1].sh1,
                ctr[i-1].sh2,
                ctr[i].sh0,
                ctr[i].sh1,
                ctr[i].sh2,
            )
        end
    end

    if isPlasma
        @inbounds Threads.@threads for i = idx0:idx1
            flux_em!(
                face[i].femL,
                face[i].femR,
                ctr[i-2].E,
                ctr[i-2].B,
                ctr[i-1].E,
                ctr[i-1].B,
                ctr[i].E,
                ctr[i].B,
                ctr[i+1].E,
                ctr[i+1].B,
                ctr[i-1].ϕ,
                ctr[i].ϕ,
                ctr[i-1].ψ,
                ctr[i].ψ,
                ctr[i-1].dx,
                ctr[i].dx,
                KS.gas.Ap,
                KS.gas.An,
                KS.gas.D,
                KS.gas.sol,
                KS.gas.χ,
                KS.gas.ν,
                dt,
            )
        end
    end

end