> Working note in Japanese, kept unedited.  Internal labels are explained in [README.md](README.md).  Where it differs from `docs/MATH.md` and `docs/REFERENCES.md`, those pages are the corrected version.

# 参考文献と確認状況

ラベル：`[F-AI]` AI（Claude）が一次資料の該当箇所を読んで確認した（確認したページを記す）。**作者本人による原文の再確認は未了**（特に Satriano Cor 1.8 と Bergh Thm A.1(e)）／`[F?]` 二次資料経由または未確認／`[C]` 本プロジェクトで計算により確認。

## 主定理の根拠

- **Bergh, D.** *Functorial destackification of tame stacks with abelian stabilisers.* Compositio Math. 153 (2017) 1257–1315. arXiv:1409.5713. `[F-AI]` pp. 1–7, 36–38 を確認（2026-09-06）。Theorem 1.2、Corollary 1.3、Definition 2.1（standard pair）、p.5 の tame の定義（AOV の意味：finite inertia ＋ linearly reductive stabilisers）、Appendix A Theorem A.1（a）–（e）、Example A.5（μ_p の非簡約作用）。**2026-09-09 追加**：§4（pp. 13–16）を逐語で確認。Algorithm A の A0–A6 全文、射線の順序の定義（「the lexicographic ordering of the power set of the set of rays」＝**錐**の順序）、および停止性の証明。A2 の錐の順序・maximal の向き・A1 の相対内部はいずれも本文に明記されており曖昧ではない。形式和 ψ の辞書式方向だけが未定義で、しかも停止性の証明はその最小性を使わない。
- **Abramovich, D., Olsson, M., Vistoli, A.** *Tame stacks in positive characteristic.* Ann. Inst. Fourier 58 (2008). arXiv:math/0703310. `[F-AI]` pp. 1–3, 9–12 を確認。Prop 2.10（locally well-split ⟹ linearly reductive）、Prop 2.13（体上で linearly reductive ⟺ locally well-split）、p.12「local abelian group schemes with no proper subgroup are α_p and μ_p; α_p is not linearly reductive」。Def 3.1・Thm 3.2 は Bergh Appendix A の引用で確認。
- **Włodarczyk, J.** *Functorial resolution by torus actions.* arXiv:2203.03090。`[F-AI]` **2026-09-09 に本文を verbatim で確認**（以前の記録にあった「PDF から定理本文を取得できていない」という留保は解消済み）。Definition 4.2.1（almost homogeneous singularity）、Theorem 4.2.2、Lemma 4.4.2、Example 4.4.3（Brieskorn：「single cobordant blow-up (after removing the vertex) suffices」「over non-perfect fields, the general case remains a challenging and unresolved problem [CPS17]」）、p.3 の二次形式に関する注意。
- **Bergh, D., Rydh, D.** *Functorial destackification and weak factorization of orbifolds.* arXiv:1905.00872. `[F?]` アブストラクトのみ（smooth を仮定）。

## 古典的な曲面特異点

- **Artin, M.** *Coverings of the rational double points in characteristic p.* In: Complex Analysis and Algebraic Geometry (Baily, Shioda eds.), Iwanami/Cambridge, 1977, pp. 11–22. `[F?]` 原論文未取得。0-形の式は Matsumoto（下記）Table 1 と arXiv:1707.04971 の表で確認、`[C]` 本プロジェクトの C1（76 件）で ADE グラフを再現。
- **Matsumoto, Y.** *Purely inseparable coverings of rational double points in positive characteristic.* arXiv:2003.10344 v3. `[F-AI]` pp. 1–6, 12–16 を確認。Table 1（0-形の式）、Table 7（Artin による étale 基本群と普遍被覆）、Convention 1.2（D_{2n+1} の指数の付け方が Artin と半整数ずれる）。
- **Liedtke, C., Martin, G., Matsumoto, Y.** *Torsors over the rational double points in characteristic p.* arXiv:2110.03650. `[F?]`
- **Pinkham, H.** *Normal surface singularities with C* action.* Math. Ann. 227 (1977) 183–193. `[F?]` Seifert 部分解消と中心曲線の自己交点 −b の公式の原典。
- **Orlik, P., Wagreich, P.** *Isolated singularities of algebraic surfaces with C* action.* Ann. of Math. 93 (1971) 205–228. `[F?]`
- **Demazure, M.** *Anneaux gradués normaux.* Séminaire Demazure–Giraud–Teissier 1979, Travaux en cours 37 (1988). `[F?]`
- **Watanabe, K.** *Some remarks concerning Demazure's construction of normal graded rings.* Nagoya Math. J. 83 (1981) 203–211. `[F?]`
- **Arnold, V. I.** 例外的 unimodal 特異点 14 種の quasi-homogeneous 代表（E_12…U_12）。`[F?]` 重みは本プロジェクトで再計算 `[C]`。

## トーリック解消（L2 の根拠）

- **Aroca, F., Gómez-Morales, M., Mourtada, H.** *Groebner fan and embedded resolutions of ideals on toric varieties.* Beitr. Algebra Geom. (2023), doi 10.1007/s13366-023-00684-0; arXiv:2202.10874. `[F-AI]` **2026-09-09 に本文を確認。L2 経路の一般的な正当化はこれで `[D]` から `[F-AI]` に上がった。**

  > **Theorem 1.3.** Let J ⊂ R_σ be a Newton non-degenerate ideal and let Y = V(J) ⊂ X_σ. Let Σ be a regular subdivision of σ which is compatible with the Groebner fan of J. Then the associated toric morphism π_Σ : X_Σ → X_σ is a **proper birational morphism**, in which irreducible components of the total transform π_Σ⁻¹(Y) are **smooth** (in particular, the **strict transform of Y is smooth**) and **meet transversely**.

  仮定と射程：
  - **標数の仮定は無い**（要旨に「without assumptions on the characteristic of the base fields」）。
  - ただし **K は perfect field**（§2 冒頭「As in the introduction K is a perfect field」）。非完全体は射程外。
  - **イデアルに対する主張**なので、超曲面だけでなく `toricResolveIdeal` の経路も覆う。
  - 「meet transversely」まで言うので、我々が別途検証している SNC もここに含まれる。
  - Remark 1.4：解消は「in a small neighbourhood of O」、つまり局所的な主張。
  - 非退化の定義（Def 1.2）は「every v ∈ σ に対し Sing(V(In_v(J))) ∩ T = ∅」。超曲面なら In_v(f) は
    Newton 多面体の面多項式なので、古典的な面条件と一致する。
  - 超曲面版は Steenbrink（Springer Proc. Math. Stat. 96, 2014）、σ = R^n_+ の場合は同著者らの先行論文。

- **Varchenko, A. N.** *Zeta-function of monodromy and Newton's diagram.* Invent. Math. 37 (1976). `[F?]` 未読。上記 Aroca–Gómez-Morales–Mourtada Thm 1.3 が任意標数（perfect 体）で同じ役割を果たすので、**もはや L2 の根拠として必要ない**。
- **Kempf, Knudsen, Mumford, Saint-Donat.** *Toroidal Embeddings I.* LNM 339 (1973). `[F?]`

## 一般の解消理論

- **Cossart, V., Piltant, O.** *Resolution of singularities of threefolds in positive characteristic I, II.* J. Algebra 320 (2008), 321 (2009). `[F?]`
- **Lipman, J.** *Desingularization of two-dimensional schemes.* Ann. of Math. 107 (1978). `[F?]`
- **Hauser, H.** *On the problem of resolution of singularities in positive characteristic.* BAMS 47 (2010). `[F?]`
- **Satriano, M.** *The Chevalley–Shephard–Todd theorem for finite linearly reductive group schemes.* Algebra & Number Theory **6** (2012) 1–26; arXiv:0911.2058. `[F-AI]` **本文を読んだ。** Corollary 1.8 の証明の第 1 段落が SEAM-3 の 3 段目そのもの：k は任意の体、U は k 上滑らかなアフィン、G は有限 linearly reductive、x ∈ U(K) が G-固定点のとき、V = m_x/m_x² への G-同変切断が Ô_{U,x} ≅ k[[V]] を G-表現として与える。代数閉体も標数の条件も不要。
- **Liedtke, C., Martin, G., Matsumoto, Y.** *Linearly reductive quotient singularities.* arXiv:2102.01067. `[F-AI]` **本文を読んだ。** Prop 6.4 が「線形化可能 ⟺ linearly reductive」。ただし k は代数閉体、作用は very small（閉点の外で自由）。我々の設定では後者が満たされないことがあるので Satriano を使う。
- **Alper, J., Hall, J., Rydh, D.** *A Luna étale slice theorem for algebraic stacks.* Ann. of Math. 191 (2020); arXiv:1504.06467. `[F-AI]` 要旨を確認。**代数閉体を仮定する**ので、任意底の Bergh Thm A.1(e) のほうが我々には適切。
- **Quek, M., Rydh, D.** *Weighted blow-ups.* 準備中／arXiv 版。`[F?]` stacky weighted blow-up の記述。
- **Milne, J. S.** *Basic Theory of Affine Group Schemes.* `[F-AI]` 標準事実（対角化可能群の部分群スキーム）。

## M2 パッケージ提出

- Macaulay2 wiki: "Writing a package", "How to submit a package"（要確認）。
- Journal of Software for Algebra and Geometry (JSAG)：パッケージ論文の投稿先（任意）。
