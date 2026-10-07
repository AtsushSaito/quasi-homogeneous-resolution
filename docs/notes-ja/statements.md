> Working note in Japanese, kept unedited.  Internal labels are explained in [README.md](README.md).  Where it differs from `docs/MATH.md` and `docs/REFERENCES.md`, those pages are the corrected version.

# 正確な主張集（statements）

このファイルは、パッケージ化と論文化のときにそのまま引用できる形で「何が、どの根拠で、どこまで」言えるかを固定する。ラベル：`[F-AI]` AI（Claude）が一次資料を読んで確認した（作者による原文の再確認は未了。docs/references.md 参照）／`[D]` 本プロジェクトの導出（未査読）／`[C]` 本プロジェクトの計算で確認（`docs/evidence-2026-09-09.md`）／`[Q]` 未解決。

## 0. 設定

- k：体、標数 p ≥ 0（主関心は p > 0）。完全性は仮定しない。
- w = (w_1,…,w_n) ∈ Z_{>0}^n、gcd(w) = 1。S = k[x_1,…,x_n]、deg x_i = w_i。
- R = S/I、I は w-斉次イデアル、R は整域、R_0 = k。X = Spec R、v = 頂点（R_+ に対応）。
- G_m は t·x_i = t^{w_i} x_i で作用。超曲面のときは I = (f)、f は w-次数 d。
- **A4**：X ∖ {v} は k 上滑らか。
- Y := Proj R（粗空間）、𝒳 := [(X ∖ {v}) / G_m]（商スタック）。

## 1. 文献から確認した定理（英文は原文どおり）

### 1.1 Bergh, Compositio 153 (2017), arXiv:1409.5713 `[F-AI]`

- p.5：「Following Abramovich, Olsson and Vistoli [AOV08], we say that X is *tame* if it has finite inertia and linearly reductive stabilisers.」
- **Definition 2.1.** Let S be a scheme and consider a pair (X, **E**)/S, where (1) X is a tame algebraic stack which is smooth and of finite presentation over S. (2) **E** = (E^1,…,E^r) is an ordered set of distinct, effective Cartier divisors on X … (standard pair).
- **Theorem 1.2 (Functorial destackification).** Let (X, **E**)/S be a standard pair, as defined in Definition 2.1, over a quasi-compact scheme S. If X has diagonalisable stabilisers, then there exists a smooth, stacky blow-up sequence Π: (X_m, **E**_m) → ⋯ → (X_0, **E**_0) = (X, **E**) which is a destackification as in Definition 2.3. In particular, the coarse space of X_m is smooth, and the coarse map can be factored as a gerbe followed by a root stack. The construction is functorial with respect to arbitrary base change S′ → S and with respect to gerbes and smooth, stabiliser preserving maps X′ → X.
- **Corollary 1.3 (Functorial desingularisation of simplicial toric singularities).** Let X be an algebraic space of finite type over an arbitrary field k. Assume that X has simplicial toric singularities only. Then there exists a sequence Π: X_m → ⋯ → X_0 = X of proper birational modifications such that X_m is smooth. The construction is functorial with respect to change of base field and with respect to smooth maps X′ → X.（p.3：simplicial toric singularities の定義は「each point ξ ∈ X has an étale neighbourhood X′ → X with X′ = U/Δ for some smooth variety U and finite diagonalisable group Δ」。「Note that no toroidal structure is needed.」）
- **Theorem A.1**（AOV Thm 3.2 の拡張）：X quasi-separated, locally of finite presentation over S, finite inertia のとき、(a) tame ⟺ (b) stabilisers linearly reductive ⟺ (c)(d) étale-locally [U/G]（G finite linearly reductive）⟺（X → S smooth のとき）(e) U smooth over S。
- p.4：「in positive characteristic, the tangent space is not well behaved. Instead, we work with the conormal bundle of the residual gerbe.」p.37：「the classifying stack Bμ_p is not étale over the base if the base is a field of characteristic p.」

### 1.2 Abramovich–Olsson–Vistoli, arXiv:math/0703310 `[F-AI]`

- Prop 2.10：Every locally well-split group scheme is linearly reductive.（対角化可能群は well-split）
- Prop 2.13：Let k be a field, G → Spec k a finite group scheme. Then G is linearly reductive if and only if it is locally well-split.
- p.12：「the only local abelian group schemes with this property are α_p and μ_p; and again α_p is not linearly reductive.」

### 1.3 Włodarczyk, arXiv:2203.03090 v4 `[F-AI]`

- **Definition 4.2.1.** Let Y ⊂ X be an integral closed subscheme defined by I_Y. A regular subscheme Z ⊂ Y is called an *almost homogeneous singularity* of Y if: (1) Sing(Y) = Z. (2) There exists a center J on X such that V(J) = Z and the weighted normal cone C_J(Y) ⊂ N_J(X) satisfies Sing(C_J(Y)) = V(in(J)) = Z.
- **Theorem 4.2.2.** Let X be a regular scheme and Y ⊂ X an integral closed subscheme with almost homogeneous singularity Z ⊂ Y for a center J. Let C_J(Y) ⊂ N_J(X) be the weighted normal cone. If either X is universally catenary, or every component of C_J(Y) ∖ Z has codimension equal to codim_X(Y), then the cobordant blow-up B_+ → X at J resolves Y: the strict transform Y′ ⊂ B_+ is regular of codimension equal to codim_X(Y).
- Lemma 4.4.2：B ≅ X × A^1 via x_i ↦ t^{w_i} x_i (i ≤ k), y ↦ t^{−1}。（本プロジェクトの Tot(L) のアトラス (X∖{v}) × A^1 と同一の構成。）
- Example 4.4.3：「In positive characteristic, if the singular locus of V(f) is contained in V(x_1,…,x_k), then by Theorem 4.2.2 the single cobordant blow-up (after removing the vertex) suffices to resolve the singularity, just as in characteristic zero. However, over non-perfect fields, the general case remains a challenging and unresolved problem. [CPS17]」
- p.3：「The output is a smooth scheme with a torus action whose geometric quotient has abelian quotient singularities. These can be resolved canonically by toroidal methods [Wło20] or by the destackification algorithm of Bergh and Rydh [BR19].」

## 2. 命題 M（確定版）

> **命題 M.** k を任意の体、R を k 上有限型の整域で N-次数付き、R_0 = k、X = Spec R、v を頂点とする。X ∖ {v} が k 上滑らかならば、k 上滑らかな X̃ と固有双有理射 π: X̃ → X で、π^{-1}(X∖{v}) → X∖{v} が同型となるものが存在する。次元・標数・p | w_i・p | d に制限はない。

**証明の骨格（各段の根拠）** `[F-AI]+[D]`

1. 𝒳 = [(X∖{v})/G_m] は k 上滑らか（G_m-トルソル X∖{v} → 𝒳 は滑らか全射）。
2. 安定化群は μ_r（Lemma L1）、inertia は有限（Lemma L1）。μ_r は対角化可能 ⟹ linearly reductive（AOV Prop 2.10）⟹ 𝒳 は tame（Bergh p.5 の定義）。p | r なら DM でない。
3. L := 指標 1 に付随する直線束。Tot(L) = [((X∖{v}) × A^1_s)/G_m]（A^1 の重み −1）。射 (u, s) ↦ s·u は G_m-不変で Tot(L) → X に降り、s ≠ 0 上で同型。Tot(L) は stacky weighted blow-up [A^{n+1}∖V(x) / G_m] の閉部分スタックなので固有（Włodarczyk Lemma 4.4.2 と同じ構成）。
4. (Tot(L), 零切断) は Bergh Def 2.1 の standard pair（smooth, tame, diagonalisable stabilisers μ_r）。Theorem 1.2 で destackification；粗空間 X̃ は k 上滑らか。開埋め込み X∖{v} ↪ Tot(L) は smooth stabiliser-preserving なので functoriality により X∖{v} 上では何も起きない。

**既知性**：Bergh Cor 1.3 ＋（古典的な）重み付き blow-up、または Włodarczyk Thm 4.2.2 / Ex 4.4.3 ＋ Bergh–Rydh。この形の明示的記述は見当たらない。

## 3. 補題 `[D]`

**L1（安定化群と inertia）.** x ∈ X∖{v}、K = {i : x_i ≠ 0} とすると Stab_x = μ_r、r = gcd(w_K)。G_m の閉部分群スキームは G_m と μ_r のみ（対角化可能群 D(M) の閉部分群は D(M/N)、M = Z）。任意の体で成立し、α_p は現れない。inertia：x_i ≠ 0 上で t·x = x は t^{w_i} = 1 を強いるので Stab ⊂ μ_{w_i} × U_i は閉、よって有限。

**L2（接空間の重み）.** P ∈ X∖{v} を K, r の点とする。𝒳 の P における接空間の μ_r-重みは、多重集合 {w_j mod r : j = 1..n} から df(P) の方向の重み 1 個（∂_{j0} f(P) ≠ 0 なる j0 の w_{j0} mod r）と、軌道方向の重み 0 を 1 個除いたもの。Tot(L) ではさらに −1 を加える。
*証明.* T_P 𝒳 = T_P X / T_P(軌道)。T_P X = ker df(P) は μ_r-安定な超平面で、その重みは全重みから df(P) の重み 1 個を除いたもの。軌道 G_m·P ≅ G_m/μ_r の接方向は「還元 Euler 場」ξ_r = Σ (w_j/r) P_j ∂_j で張られ（gcd(w_K/r) = 1 なので 0 でない）、μ_r で固定されるので重み 0。
*注意 `[C]`.* p | w_i のとき素朴なスライス Z = X ∩ {x_i = 1} は特異になりうる（E_8^0, char 2, x = 1 上の (y,z) = (0,1)）。Z → [Z/μ_{w_i}] は μ_p-トルソルなので、スタックが滑らかでも Z は滑らかとは限らない。上の重みの計算は X∖{v} で行っているのでこの影響を受けない。

**L3（局所型）.** X′ = Tot(L) の粗空間は P の像の étale 近傍で A^{n−1}/μ_r（重みは L2 のもの）。n = 3 では擬鏡映を除いて 1/r′(1,q) に正規化し、極小解消は r′/q の Hirzebruch–Jung 連分数 [b_1,…,b_k] の鎖。`[F-AI]`（étale 局所構造は Bergh Thm A.1(e)＋対角化可能群の線形化）。

**L4（曲面の予測グラフ）.** n = 3、A4 のとき X̃ の例外集合は星型：中心曲線 Y ≅ Proj R、腕は各層別点の HJ 鎖。
- 種数 g(Y) = dim_k R_a、a = d − Σ w_i（a < 0 なら 0）。（Demazure 表示と Gorenstein 双対性 [H^2_m(R)]_0 ≅ (R_a)^∨。）
- Y² = −b、b = d/(w_1 w_2 w_3) + Σ_i deg(P_i)·β_i/α_i、腕 i が 1/α_i(1, β_i) のとき。`[C]` 279 曲面で一致。慣例：E_8 = (2,3,5) で b = 1/30 + (1/2 + 2/3 + 4/5) = 2。
- 例外曲線本数 = 1 + Σ deg(P_i)·k_i。

**L5（自己交点の計算）.** X̃ ⊂ T（トーリック多様体、射線 u）で、div(x_i)|_{X̃} = Σ_u ⟨e_i,u⟩ D_u|_{X̃} が主因子なので、コンパクトな成分 C に対し Σ_u ⟨e_i,u⟩ (D_u|_{X̃}·C) = 0。C ⊂ D_u なら D_u|_{X̃}·C = Σ_{C′≠C} m^u_{C′}(C′·C) + m^u_C C²、そうでなければ (y_u, ft) + Q_C の長さ。i ごとの値の一致が一貫性チェック。`[C]`

**L6（正則版：k が F_p 上有限生成のとき）.** A4 を「X∖{v} が正則」に弱めても、k が F_p 上有限生成なら正則な固有双有理モデル X̃ → X（X∖{v} 上同型）が存在する。
*証明.* 係数を含む有限生成 F_p-代数 A ⊂ k（Frac A = k）上に R_A を取り、S = Spec A。X_A∖v_A の非正則点集合は閉で、生成ファイバー（局所環が X∖{v} の局所環）に触れないので、その像の閉包を S から除いて X_A∖v_A を正則にする。F_p は完全体なので正則 ⟺ F_p 上滑らか。Bergh Thm 1.2 を底 Spec F_p で Tot(L_A) に適用し、X̃_A を得る。X̃ := X̃_A ×_S Spec k の局所環は X̃_A の局所環（生成ファイバーは局所化）なので正則。固有・双有理・X∖{v} 上同型は底変換で保たれる。X̃ は k 上滑らかとは限らない。
*一般の k* `[Q]`：正則性は非分離拡大で保たれないため降下できない。Bergh Thm 1.2 と Bergh–Rydh は smooth を仮定する。

**L7（A3 の緩和）.** R は正規でなく整域で足りる。証明の骨格は正規性を使わない（Demazure 表示は不要）。`[C]` 有理 4 次曲線上の非正規錐が blow-up 1 回で滑らか。

**L8（トーリック不変な腕）.** 層別点が P(w) のトーラス固定点（K が 1 元）のとき、腕の例外曲線はトーリック解消 T のトーラス不変曲線 V(v, v′) で、D_v のトーラス内には現れない。`[C]`

## 4. トーリック経路（L2）の正当性

**命題 T.** f が w-斉次で convenient かつ Newton 非退化（各座標面 J について f_J のトーラス上の零点集合が滑らか）なら、重み付き blow-up の扇の任意の滑らかな細分 Σ に対し、strict transform は X_Σ の全チャートで滑らかで、X_Σ → A^n は原点の外で同型。`[F?]`（Varchenko 型。証明は Jacobi 判定のみを使うので任意標数）。
- 非退化は A4 より強い。A4 かつ退化な例 780 件（p = 2,3,5）でも全件通ったが、理論的保証はない `[C]`。
- 本プロジェクトの実装は「解消の存在」を各例で直接証明する（チャートごとの Jacobi 判定）。Bergh の定理には依存しない。

## 5. 言えないこと

- 一般の特異点の解消、非孤立の quasi-homogeneous、非完全体一般での正則版、極小性、G_m-同変性（functoriality から同変性は出るが未検証）。
