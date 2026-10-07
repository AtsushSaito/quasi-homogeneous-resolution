> Working note in Japanese, kept unedited.  Internal labels are explained in [README.md](README.md).  Where it differs from `docs/MATH.md` and `docs/REFERENCES.md`, those pages are the corrected version.

# Bergh の脱スタック化アルゴリズム（原文と実装の対応）

出典：D. Bergh, *Functorial destackification of tame stacks with abelian stabilisers*,
Compositio Math. 153 (2017) 1257–1315 = arXiv:1409.5713。以下は pp. 8–16, 25–30 を本文で確認したもの `[F-AI]`。

## 定義

**Def 2.6（distinguished structure）** stack–divisor pair (X, **E**)/S に対し **D** ⊆ **E** で、**D** のすべての因子が **E** ∖ **D** の因子より若いものを取る。(X, **E**, **D**)/S を distinguished structure を持つ pair と呼び、**D** に属する成分を distinguished という。stacky blow-up が admissible とは中心が **D** の台に含まれること。変換 (X′, **E**′, **D**′) では **D**′ は例外因子と **D** の strict transform からなる。

**Def 3.2（stacky fan）** 三つ組 **Σ** = (N, Σ, β)。N は有限生成アーベル群、Σ は N_R の単体的扇で |Σ| が N_R を張る、β: Z^{Σ(1)} → N は各生成元 ρ を射線 ρ 上の非零格子点に送る群準同型。

> **実装**：N = Z^n（自由）なので β(ρ) = ℓ_ρ·u_ρ（u_ρ は原始生成元、ℓ_ρ ∈ Z_{>0}）。よって `rays`（原始生成元）と `labels`（ℓ_ρ）の対で忠実に表せる。射線には順序を付ける（p.14「we will assume that the rays of the stacky fan are ordered」）。

**Def 3.5（star subdivision）** σ ∈ Σ に対し **v = Σ_{ρ∈σ(1)} β(ρ)**。v が生成する射線を ρ_0 とし、Σ に ρ_0 を加えて σ を含む各錐を細分する。β は ρ_0 ↦ v で延長する。ρ_0 を例外射線と呼ぶ。

> **実装**：`starSubdivSF`。u = v/gcd(v)、ℓ = gcd(v)。**新しい射線のラベルが 1 とは限らない**のが要点。

**§3.5（multiplicity）** P_σ = {Σ λ_i u_i | 0 ≤ λ_i < 1}（u_i は**原始**生成元）の格子点の個数。「**the stacky structure β plays no part in the definition of multiplicity. In particular, the multiplicity of a cone is preserved by the root construction.**」

> **実装**：`multSF` は原始生成元の r×r 小行列式の gcd。ラベルを一切使わない。

**Def 3.6（root construction）** 射線の集合 **ρ** = {ρ_1,…,ρ_r} と正整数の重み d に対し、β′(ρ) = **d**(ρ)β(ρ)（ρ ∈ **ρ**）、β′(ρ) = β(ρ)（それ以外）。記号 **Σ**_{**d**^{-1}**ρ**}。

> **実装**：`rootSF` はラベルを**掛ける**。

**Def 3.8（independency）** ρ ∈ σ(1) が σ で independent とは mult τ = mult σ（τ は σ(1) ∖ ρ が張る面）。

## Algorithm A（Partial Toric Destackification, p.14）

入力：distinguished structure を持つ stacky fan **Σ**_0。出力：admissible な stacky modification の列で、**Σ**_n の distinguished 射線がすべて independent になるもの。

- **A0** i = 0。
- **A1** [Check if finished] σ(1) が distinguished 因子を含み、かつ P_σ の**相対内部**に格子点を含む錐 σ ∈ **Σ**_i の集合を S とする。S が空なら終了。
- **A2** [Choose a formal sum of rays] S の錐を「非 distinguished な extremal ray の本数」で、次に「重複度」で順序付ける。この順序で**最大**の部分集合を S_max とする。σ ∈ S_max の P_σ 内の格子点を β_i(ψ) の射線が通るような射線の形式和 ψ の集合を P とする。**辞書式で最小**の元を ψ_i とする。
- **A3** [Root distinguished rays] ψ_i = d_1ρ_1+⋯+d_sρ_s+c_1δ_1+⋯+c_rδ_r（ρ 非 distinguished、δ distinguished）とする。root construction (**Σ**_i)_{c_1^{-1}δ_1,…,c_r^{-1}δ_r} → **Σ**_i を施し、ψ_{i+1} = d_1ρ_1+⋯+d_sρ_s+δ_1+⋯+δ_r とする。
- **A4** [Perform a stacky star subdivision] σ_i を ψ_i の台が生成する錐とする。stacky star subdivision **Σ**_i(σ_i) → **Σ**_i を行い、例外射線を ε_{i+1} とする。ψ_{i+1} = ψ_i − Σ_{ρ∈σ_i(1)} ρ + ε_{i+1}。
- **A5** [Iterate inner loop] ψ_i の台が 2 本以上の射線を含む間、A4 を繰り返す。
- **A6** [Iterate main loop] A1 へ。

**変換則**（Bergh が A3・A4 の各所で明記）：β_i(ψ_i) = β_{i-1}(ψ_{i-1})。

> **実装**：`algorithmA`。変換則は全ステップで `assert` している。これが実装のバグ検出に直結する。

## Algorithm B（Functorial Toric Destackification, p.16）

- **B0** i = 0。
- **B1** [Choose a cone] σ(1) のどの射線も σ で independent でない錐 σ ∈ **Σ**_i の集合を S とする。空なら終了（このとき **Σ**_i のすべての射線が independent、すなわち全錐が滑らか）。最大次元の σ ∈ S を選ぶ。複数あれば錐の自然な順序（射線の順序から誘導される冪集合の辞書式順序）で最大のものを取る。
- **B2** [Create distinguished ray] **Σ**_{i+1} → **Σ**_i を σ での star subdivision とする。
- **B3** [Resolve the cone] 細分の例外射線だけを distinguished とし、Algorithm A を呼ぶ。
- **B4** [Iterate] distinguished structure を忘れて B1 へ。

## 実装で分かったこと `[C]`

1. **終了条件はラベルではなく重複度**。提案書は「重複度 1 かつラベル 1」を destackified としていたが誤り。Bergh Thm 1.2 が保証するのは**粗空間が滑らか**（全錐の重複度 1）であり、**ラベルは 1 にならない**。残ったラベルは root stack の構造を表す。実際 1/3(1,2) の出力はラベル {1,1,1,3,3}。
2. **Bergh のアルゴリズムは極小解消を与えない**。関手性を優先しているため。1/3(1,2)（= A_2）の出力は自己交点 {−3,−1,−3} の 3 本。(−1) 曲線を潰すと {−2,−2} = HJ(3,2) になる。
3. **鎖は非常に長くなりうる**。r ≤ 10 の巡回商 31 個で最長 356 本、全体で 524 秒。極小化後は全件 HJ と一致（`tests/test_algorithmB.m2`）。実用上は `minimalizeChain` で事後処理する。
4. **star subdivision の新射線は原始とは限らない**。v = Σβ(ρ) を原始化した余りがラベルになる。ここを見落とすと格子が壊れる。
5. **単一射線の錐は S に入らない**。P_σ の相対内部に格子点があるのは σ の次元が 2 以上のときのみ（原始生成元だから）。よって A4 の内側ループは必ず 2 本以上の台から始まり、無限ループにならない。

## 検証状況

| 項目 | 結果 |
|---|---|
| 重複度（MS1） | (1,0),(1,3) → 3、(1,0),(0,1) → 1 ✓ |
| 基本トーリックスタック | 1/2(1,1) → mult 2、1/2(1,0) → mult 1・ラベル 2（擬鏡映）✓ |
| Algorithm B（MS4/MS5） | **r ≤ 10 の巡回商 31 個すべてで、極小化後の鎖 = HJ 連分数。不一致 0** |
| Bergh Example 4.1 | Z/5・重み (1,3) で停止し、極小化後 {3,2} = HJ(5,2)（1/5(1,3) ≅ 1/5(1,2)、2·3 ≡ 1 mod 5）✓ |
| 変換則 β(ψ) 不変 | 全ステップで成立 |

## 局所モデルをどう貼り合わせるか

定義（Cor 1.3、p.3）は **étale 局所**である。各点のまわりで U/Δ の形になっていればよく、標数にも次元にも依存しない。問題は、局所の解消処方をどう大域的な 1 つの操作にするか。

Bergh 自身がこれを明示している（p.13–14、Algorithm A の直前）`[F-AI]`：

> Roughly, destackification is achieved as follows. We blow up the most singular part and mark the
> exceptional divisor as *distinguished*. Then we make the distinguished divisors *independent* by
> using a sequence of *admissible* stacky blow-ups. This is described in Algorithm A. **In
> particular, only the locus lying over the original problematic locus will be modified. This
> ensures that destackifying the whole toric stack is compatible with destackifying each toric open
> substack separately and then gluing together.**

貼り合わせを可能にしている仕掛けは 3 つある。

### 1. 中心を「内在的な不変量」で決める（選択をしない）

局所処方が貼り合うためには、処方が**同型で保たれるデータだけ**で決まっていなければならない。Bergh はそのために conormal invariants を導入する（§7）：independency index（Def 7.1）、toroidal index（Def 7.2）、divisorial type（Def 7.4）、divisorial index（Def 7.6）。いずれも安定化群の residual gerbe の conormal 表現から定まり、選択を含まない。

**正標数での要点**（p.4）`[F-AI]`：

> In characteristic 0, we could have worked with the canonical action of the stabiliser on the
> tangent space at each point, but **in positive characteristic, the tangent space is not well
> behaved. Instead, we work with the conormal bundle of the residual gerbe.**

つまり char 0 の素朴な道具（接空間）が char p では関手的でないので、conormal に置き換えている。ここが「標数に依存しない貼り合わせ」を支えている。

なお不変量が最大になる軌跡は一般には滑らかでなく、そのままでは blow up できない（p.13）。そこで複数の不変量を交互に使って、滑らかな中心を切り出す。

### 2. 因子に順序を付ける（組合せ的な選択を標準化する）

p.14：「we will assume that the rays of the stacky fan are ordered. Note that the ordering of the rays also induces an ordering on the cones」。順序という**追加の構造を持ち回る**ことで、A2 の「どの錐を選ぶか」「どの格子点を選ぶか」が一意に決まる。順序が無ければ選択が生じ、貼り合わない。

（我々が OI-1 で詰まっているのは、まさにこの順序の定義が A2 で曖昧なため。）

### 3. distinguished structure（触ってよい範囲を限定する）

Def 2.6。例外因子を distinguished と印を付け、中心がその台に含まれる blow-up（admissible）だけを許す。これにより**元から問題だった軌跡の上しか変更されない**。だから開部分ごとに実行して貼り合わせても、全体で実行したのと同じになる。

### 我々の場合はもっと易しい `[C]`

`tests/stratum_constancy.m2` で、層に沿って横断モデルが一定であること、さらに各 X′ 上で横断モデルが**1 種類しかない**ことを確認した。処方が 1 つなので、整合条件が実際には発生しない。

**ただし残る隙間**：安定化群 μ_r の**同一視のモノドロミー**（層を一周したときの Aut(μ_r) の作用）は調べていない。特異点の型は不変なので粗空間は変わらないが、局所処方を素朴な積として貼る記述は捻れうる。一般論ではここを上の関手性が吸収する。SEAM-4・SEAM-5 を参照。
