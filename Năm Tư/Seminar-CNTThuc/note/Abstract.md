# Abstract

- Bert cho bài toán phân loại tài liệu
- trong 1 vài đặc điểm của nhiệm vụ khiến Bert không phải là phù hợp nhất:
  - các cấu trúc cú pháp ít quan trọng hơn đối với các loại nội dung
  - tài liệu thường dài hơn đầu vào thông thường của Bert 
  - các tài liệu thường có nhiều nhãn cùng 1 lúc

- tuy nhiên Mô hình phân loại đơn giản sử dụng Bert vẫn có thể đặt SOTA (state of the art) trên 4 bộ dữ liệu phổ biến nhất.
- để giải quyết chi phí tính toán liên quan đến suy luận Bert: 
  + Knowledge Distillation – Chắt lọc tri thức
  + từ $Bert_{large}$ thành LSTMs 2 chiều nhỏ hơn (**bidirectional LSTM - BiLSTM**)

    => đạt được tương đương với $Bert_{base}$ trên nhiều bộ dữ liệu nhưng sử dụng ít hơn 30 lần tham số

=> đóng vai trò chính trong bài báo là đưa ra baseline được cải tiến, có thể làm nền tảng cho tương lai

> **câu hỏi:** nếu dùng chuyển từ $Bert_{large}$ về LSTMs nhưng lại có hiệu suất tương đương $Bert_{base}$ thì sao không dùng $Bert_{base}$ luôn

# 1. Introduction

- gần đây, cách tiếp cận bài toán trong NLP chủ yếu tập chung vào thiết kế kiến trúc nerual network sử dụng
  + dữ liệu cho tasks cụ thể 
  + word embeddings (GloVe, word2vec, fastext, ...) 

- Tuy nhiên, trong cộng đồng NLP đã có 1 sự thay đổi mang tính bước ngoặc trong tiếp cận mô hình
  + chuyển sang mô hình học sâu sẵn (pre-train model) 
  + đạt SOTA trong những tác vụ như: 
    + hỏi đáp 
    + phân tích cảm xúc 

- Bert (Bidirectional Encoder representions from tranformers) (2019)
  + vượt trội hơn tất cả những thế hệ trước (ELMO, GPT) với khoảng cách lớn trong nhiều tác vụ NLP
  + cách tiếp cận này có 2 giai đoạn:
  + Bert (pre-trained trên lượng lớn văn bản với unsupervised objective)
  + pre-trained network này sau đó được fine-tuned trên những task cụ thể và dữ liệu gán nhãn 

=> những Bert chưa được fine-tuned cho document classification 

## Tại sao điều này đáng được khám phá ?
- **Thứ nhất**, việc mô hình hóa cấu trúc cú pháp được cho là ít quan trọng hơn trong bài toán document classification so với tác vụ thông thường của Bert như:    
    + suy luận ngôn ngữ 
    + diễn đạt lại câu 

=> nhận định này đúng vì mô hình (logistic regression) và SVM là các mô hình baseline đặc biệt mạnh mẽ trong document classification 


- **Thứ hai**, documents thường nhiều nhãn và nhiều lớp 



## Trong paper

- mô tả fine-tuning Bert cho document classification để đạt được kết quả SOTA trên 4 bộ dữ liệu phổ biến
- tuy nhiên tăng chất lượng cho model thì cũng đi kèm với chi phí tính toán cao

  + Bert chứa hàng trăm triệu tham số 
  + trong khi baseline trước đó sử dụng ít hơn 4 triệu và thực hiện nhanh hơn gấp 40 lần 

- để giảm gánh nặng tính toán:
  + áp dụng Knowledge Distillation (Chắt lọc tri thức) để chuyển giao kiến thức từ $Bert_{large}$
  + biến thể $Bert_{large}$ sang mô hình nhỏ hơn BiLSTM (bidirectional LSTM)

=> đạt được kết quả tương đương được với Bert\_base biến thể Bert nhỏ hơn bằng cách sử dụng 1 mô hình ít tham số hơn 30 lần.



## Đóng góp trong paper này
- Thiết lập kết quả SOTA cho document classification bằng cách đơn giản là fine-tuned Bert 
- Bert có thể chắt lọc thành mô hình neural đơn giản hơn nhưng vẫn cung cấp độ chính xác cạnh tranh ở chi phí tính toán khiêm tốn hơn


# 2. Background and related 
- kiến trúc nerual netword đã chiếm ưu thế trong task of document classification 
- Bert tốt những nó có số lượng tham số rất lớn, yêu cầu mức tính toán đáng kể 
- Knowledge distillation - KD (chắt lọc tri thức)
	+ một kĩ thuật nén hiệu quả 
	+ **chắt lọc** thông đã học được từ model lớn (the teacher) sang model nhỏ hơn (the student)
	+ sử dụng xác suất phân lớp bởi pre-trained teacher (nhãn mềm - soft targets) để train cho model student trên tập dữ liệu tranfer 

# 3. Our approach 
- để điều chỉnh $Bert_{base}$ và $Bert_{large}$ cho document classification 
- thêm một tầng fully-connected lên trạng thái ẩn cuối cùng tương ứng với token đầu vào [CLS] (classification token).
- trong quá trình fine-tuning, đã tối ưu toán bộ model từ đầu đến cuối 
	+ với bộ tham số softmax classifier bổ sung $W \in \mathbb{R}^{K \times H}$
		+ H là kích thước của vector trạng thái ẩn 
		+ K là số lượng nhãn (classes)
	+ tối thiểu hàm mất mát cross-entropy cho bài toán single-label và hàm mất mát binay cross-entropy cho bài toán multi-label 
- tiếp theo, KD từ fine-tuned $Bert_{large}$ thành $LSTM_{reg}$ nhỏ hơn nhiều
- thực hiện quá trình (Knowledge Distillation – KD) bằng cách 
	+ sử dụng các mẫu huấn luyện (training examples)
	+ kèm theo một vài phép tăng cường dữ liệu nhỏ (minor augmentations)
	+ để tạo thành transfer set.

- kết hợp hai objectives củ classification cho mỗi trong mẫu trong tập chuyển giao (transfer set):
	+ $\mathcal{L}_{classification}$ sử dụng target labels để tối ưu hàm mất mát cross-entropy và binary cross-entropy tiêu chuẩn 
		+ tùy thuộc vào tập dữ liệu multi-label hoặc single-label 
	+ $\mathcal{L}_{distill}$ sử dụng soft tartgets để tối ưu hóa độ chênh lệch Kullback–Leibler (KL) 
		+ ký hiệu: $KL(p||q)$
			+ `p` và `q` là xác suất phân lớp được sinh ra bởi student model và teacher model 

**Hàm mục tiêu:**
$$
\mathcal{L} = \mathcal{L}_{classication} + \lambda . \mathcal{L}_{distill} \space (1)
$$
trong đó $\lambda \in \mathbb{R}$ là hệ số trọng số dùng để cân bằng mức độ đóng góp của hai hàm mất mát vào mục tiêu huấn luyện tổng thể.
			
> **câu hỏi:** $\lambda$ là gì và nếu nó thay đổi thì như thế nào 

# 4. Experimental Setup

- so sánh các mô hình Bert đã fine-tune với các mô hình khác gồm `HAN`, `KimCNN`, `XMLCNN`, `SGM`, và `LSTMreg`.

![image-1](https://hackmd.io/_uploads/SklObEo1We.png)



+ sử dụng GPU Nvidia Tesla V100 và P100 để fine-tune mô hình Bert, và thực hiện các thí nghiệm còn lại trên RTX 2080 Ti và GTX 1080.
+ sử dụng PyTorch 0.4.1 làm framework backend, và Scikit-learn 0.19.2 để tính toán các vector tf–idf cũng như triển khai các mô hình Logistic Regression (LR) và Support Vector Machine (SVM).
+ lấy ngẫu nhiên 80% dữ liệu để huấn luyện, và 10% cho mỗi phần: xác thực (validation) và kiểm thử (test).

##  Training and Hyperparameters
### 1. Khi fine-tuning Bert
đã tối ưu các siêu tham số gồm:
+ Số epoch (epochs)
+ Kích thước batch (batch size)
+ Tốc độ học (learning rate)
+ Độ dài chuỗi tối đa (Maximum Sequence Length – MSL),
  + tức là số lượng token tối đa mà mỗi tài liệu sẽ bị cắt ngắn (truncated).

Nhận thấy rằng **chất lượng của mô hình rất nhạy cảm với số lượng epoch**, do đó cần phải điều chỉnh riêng cho từng bộ dữ liệu.

Cụ thể, huấn luyện:
+ Reuters trong 30 epoch,
+ AAPD trong 20 epoch,
+ IMDB trong 4 epoch, và do hạn chế về tài nguyên, chúng tôi chỉ huấn luyện Yelp trong 1 epoch.

Nhận thấy rằng việc chọn kích thước
+  **batch (batch size)** là 16
+  tốc độ học (**learning rate**) là $2 \times 10^{-5}$
+  độ dài chuỗi tối đa (**MSL – Maximum Sequence Length**) là 512 token 
  
=> cho ra hiệu suất tối ưu trên các bộ validation sets.

### 2. Đối với quá trình distillation 
Huấn luyện mô hình $LSTM_{reg}$ để học lại các biểu diễn (representations) đã được học từ $Bert_{large}$, sử dụng hàm mục tiêu được mô tả trong Phương trình (1).
+ sử dụng kích thước batch là 128 cho các tác vụ (multi-label) 
+ sử dụng kích thước batch là 64 cho các tác vụ (single-label).

Nhận thấy rằng tốc độ học (learning rate) và tỷ lệ dropout được sử dụng trong nghiên cứu của Adhikari et al. (2019) cũng tối ưu cho quá trình distillation này.

Để xây dựng một tập chuyển giao (transfer set) hiệu quả cho quá trình distillation như được đề xuất bởi Hinton et al. (2015), chúng tôi mở rộng (augment) các tập huấn luyện của bộ dữ liệu bằng cách áp dụng:
+ hoán đổi từ có hướng dẫn theo loại từ (POS-guided word swapping) và
+ che ngẫu nhiên từ (random masking) (Tang et al., 2019).

Kích thước của tập chuyển giao (transfer set) đối với các bộ dữ liệu Reuters, IMDB và AAPD lần lượt gấp 3 lần, 4 lần, và 4 lần kích thước của tập huấn luyện tương ứng.

Trong khi đó, do hạn chế về tài nguyên tính toán, đối với Yelp 2014, tập chuyển giao chỉ có kích thước bằng đúng (1 lần) tập huấn luyện (tức không áp dụng tăng cường dữ liệu).

Sử dụng giá trị:
+ $\lambda = 1$ cho các bộ dữ liệu đa nhãn (multi-label) 
+ $\lambda = 4$ cho các bộ dữ liệu đơn nhãn (single-label).


#  5. Results and Discussion
Điểm F1-scores cho các tập dữ liệu đa nhãn và độ chính xác (accuracy) cho các tập dữ liệu đơn nhãn, cùng với độ lệch chuẩn tương ứng, được run năm lần.
 
![image](https://hackmd.io/_uploads/BJ7KbVj1Zl.png)


**Nhận xét:** $Bert_{large}$ đạt được hiệu suất hàng đầu (state-of-the-art) trên cả bốn tập dữ liệu, theo sau là $Bert_{base}$ (hàng 10 và 11). Mô hình $LSTM_{reg}$ (hàng 9), dù đơn giản hơn nhiều, vẫn đạt điểm số cao, gần tiệm cận với chất lượng của $Bert_{base}$.

Tuy nhiên, cần lưu ý rằng tất cả các mô hình nằm trên hàng 10 chỉ cần một phần nhỏ thời gian và bộ nhớ so với mức yêu cầu để huấn luyện các mô hình Bert.

Đáng ngạc nhiên là distilled $LSTM_{reg}$ ($KD-LSTM_{reg}$, hàng 12) đạt hiệu suất tương đương với $Bert_{base}$ về trung bình trên các tập dữ liệu Reuters, AAPD và IMDB.

Thực tế, mô hình này thậm chí còn vượt qua $Bert_{base}$ trong ít nhất một trong năm lần chạy.

Đối với Yelp, ta thấy rằng $KD-LSTM_{reg}$ giúp thu hẹp khoảng cách giữa $Bert_{base}$ và $LSTM_{reg}$, nhưng không đáng kể bằng so với các tập dữ liệu còn lại.

![image-2](https://hackmd.io/_uploads/ByjtWVsJ-l.png)


Để có cái nhìn tổng quan hơn, Bảng 3 trình bày thời gian suy luận (inference time) trên tập xác thực của tất cả các tập dữ liệu.

Chúng tôi tính thời gian suy luận với kích thước batch là 128 cho tất cả các tập dữ liệu, chạy trên một GPU RTX 2080 Ti.

Kết quả cho thấy $KD-LSTM_{reg}$ đạt tốc độ nhanh hơn ít nhất khoảng 40 lần so với $Bert_{base}$.

Ngoài ra, figure 1 trình bày so sánh giữa số lượng tham số và chất lượng dự đoán trên các tập xác thực.
Các biểu đồ này cho thấy hiệu quả của mô hình $KD-LSTM_{reg}$ với các số lượng nút ẩn khác nhau: 32, 64, 128, 256 và 512.

Chúng tôi nhận thấy rằng $KD-LSTM_{reg}$ chỉ với 256 nút ẩn (tức khoảng $1\%$ số tham số của $Bert_{base}$) đã đạt hiệu suất tương đương với $Bert_{base}$ trên tập Reuters;
trong khi đó, đối với AAPD, 512 nút ẩn (tức khoảng $3\%$ số tham số của $Bert_{base}$) là đủ để vượt qua $Bert_{base}$.

# 6. Conclusion and Future Work

Trong bài báo này, chúng tôi cải thiện các mô hình chuẩn (baseline) cho bài toán phân loại văn bản bằng cách tinh chỉnh (fine-tune) mô hình Bert.
Chúng tôi cũng sử dụng tri thức mà các mô hình Bert đã học được để nâng cao hiệu quả của một mô hình BiLSTM đơn tầng, nhẹ, gọi là LSTMreg, thông qua kỹ thuật tri chưng tri thức (knowledge distillation).

Thực tế, chúng tôi cho thấy rằng mô hình LSTMreg sau khi được distill đạt hiệu năng tương đương với Bertbase trên phần lớn các tập dữ liệu, đồng thời mang lại:

+ Giảm hơn 30 lần về số lượng tham số
+ Và tốc độ suy luận nhanh hơn ít nhất 40 lần.

## For future work
Nghiên cứu trong tương lai có thể tập trung vào việc phân tích tác động của kỹ thuật (knownledge distillation) trên nhiều kiến trúc mạng nơ-ron khác nhau.

Ngoài ra, việc phát triển các kỹ thuật nén mô hình chuyên biệt trong bối cảnh các mô hình transformer cũng là một hướng nghiên cứu đáng được khám phá.

# Câu hỏi thảo luận
|100 câu hỏi vì sao|
------
|1. Mục tiêu chính của bài báo DocBERT là gì?|
|2. Tại sao nhóm tác giả cho rằng việc áp dụng BERT cho phân loại tài liệu là đáng nghiên cứu?|
|3. Trước DocBERT, những hướng tiếp cận phổ biến nào được dùng cho phân loại tài liệu?|
|4. Vì sao mô hình BERT ban đầu bị xem là không phù hợp cho phân loại tài liệu?|
|5. Những đặc điểm nào khiến tài liệu khác biệt so với câu hoặc đoạn văn trong NLP?|
|6. Tại sao cấu trúc cú pháp ít quan trọng hơn trong phân loại tài liệu?|
|7. Tác giả nhận thấy gì về hiệu quả của các mô hình tuyến tính như Logistic Regression và SVM?|
|8. Bài báo muốn chứng minh điều gì thông qua việc fine-tune BERT cho phân loại tài liệu?
|9. Thách thức lớn nhất khi áp dụng BERT cho tài liệu dài là gì?
|10. BERT được so sánh với những mô hình tiền huấn luyện nào khác trong bài báo?
|11. BERT có những ưu điểm nào so với ELMo và GPT trong ngữ cảnh này?
|12. Quá trình pre-training của BERT gồm những nhiệm vụ nào?
|13. Vì sao “masked language modeling” và “next-sentence prediction” lại quan trọng với BERT?
|14. DocBERT đại diện cho sự thay đổi nào trong hướng tiếp cận NLP hiện nay?
|15. Vai trò của quá trình fine-tuning trong BERT là gì?
|16. Theo tác giả, những lý do nào khiến Document Classification đáng được tái nghiên cứu bằng BERT?
|17. Tác giả đề cập đến những giới hạn nào của các mô hình CNN và HAN truyền thống?
|18. Bài báo muốn đóng góp gì cho cộng đồng nghiên cứu NLP?
|19. Mục tiêu phụ của nghiên cứu này ngoài việc đạt SOTA là gì?
|20. Vì sao nhóm tác giả chọn tập trung vào hiệu quả tính toán và tốc độ suy luận?
|
|21. Các mô hình XML-CNN và KimCNN khác nhau ở điểm nào?
|22. HAN (Hierarchical Attention Network) hoạt động dựa trên nguyên tắc nào?
|23. Vì sao HAN phù hợp cho dữ liệu có cấu trúc nhiều tầng như tài liệu?
|24. Mô hình SGM (Sequence Generation Model) có ưu điểm gì trong phân loại đa nhãn?
|25. LSTMreg được giới thiệu bởi ai và có đặc điểm gì nổi bật?
|26. LSTMreg được xem là baseline mạnh vì lý do nào?
|27. Tại sao tác giả chọn LSTMreg làm mô hình đích để distill?
|28. Các kỹ thuật nén mô hình truyền thống như pruning khác Knowledge Distillation ở điểm nào?
|29. Tác giả nhắc đến những công trình nào về pruning và sparsification?
|30. Knowledge Distillation được Hinton et al. (2015) định nghĩa như thế nào?
|31. Mục tiêu của quá trình “distilling” là gì?
|32. Trong Distillation, khái niệm “teacher” và “student” model có ý nghĩa gì?
|33. Vì sao KD được xem là phương pháp “model-agnostic”?
|34. Những ứng dụng khác của Knowledge Distillation trong NLP là gì?
|35. KD giúp giảm chi phí suy luận như thế nào?
|36. Những yếu tố nào ảnh hưởng đến hiệu quả của quá trình KD?
|37. KD khác với transfer learning ở điểm nào?
|38. Trong bài này, tác giả kết hợp KD với fine-tuning BERT như thế nào?
|39. Có những hạn chế nào của KD khi áp dụng cho bài toán phân loại tài liệu?
|40. KD-LSTMreg khác LSTMreg truyền thống ở điểm nào?
|
|41. Cấu trúc đầu ra của BERT được điều chỉnh như thế nào trong DocBERT?
|42. Vai trò của token [CLS] trong mô hình là gì?
|43. Hàm mất mát nào được dùng cho bài toán phân loại đơn nhãn?
|44. Hàm mất mát nào được dùng cho bài toán phân loại đa nhãn?
|45. Tác giả kết hợp hai hàm mất mát như thế nào trong quá trình KD?
|46. Công thức tổng quát của hàm mất mát cuối cùng là gì?
|47. Ý nghĩa của tham số λ trong phương trình (1) là gì?
|48. Tại sao cần kết hợp cả loss phân loại và loss distillation?
|49. KL-divergence được dùng để đo lường điều gì trong quá trình KD?
|50. “Soft targets” trong KD là gì và khác “hard targets” ra sao?
|51. Mô hình BiLSTM được chọn vì lý do gì?
|52. Các tham số chính của LSTMreg gồm những gì?
|53. Vì sao tác giả không sử dụng CNN làm mô hình student?
|54. Làm thế nào để huấn luyện KD-LSTMreg trên tập transfer?
|55. Những loại tăng cường dữ liệu (augmentation) nào được sử dụng?
|56. POS-guided word swapping có tác dụng gì?
|57. Random masking giúp cải thiện quá trình học ra sao?
|58. Tại sao Yelp2014 không áp dụng data augmentation?
|59. Việc tăng kích thước tập transfer ảnh hưởng thế nào đến kết quả KD?
|60. Quá trình fine-tuning được thực hiện end-to-end hay chỉ trên classifier?
|
|61. Các bộ dữ liệu được sử dụng gồm những cái tên nào?
|62. Bộ dữ liệu nào là đa nhãn và bộ nào là đơn nhãn?
|63. Nguồn gốc của các bộ dữ liệu đó là gì?
|64. Ý nghĩa của các cột C, N, W, S trong Bảng 1 là gì?
|65. Vì sao Reuters và AAPD được chọn làm bài toán đa nhãn?
|66. Cách chia tập train/validation/test được mô tả như thế nào?
|67. Tác giả dùng phần cứng gì cho việc huấn luyện BERT?
|68. Các phiên bản GPU khác nhau có vai trò gì trong quá trình thử nghiệm?
|69. Tác giả sử dụng thư viện nào để triển khai BERT?
|70. Scikit-learn được dùng trong phần nào của thí nghiệm?
|71. Bộ công cụ Hedwig có vai trò gì trong nghiên cứu?
|72. Các mô hình baseline nào được so sánh với BERT?
|73. Thông số batch size, learning rate và max sequence length (MSL) được chọn như thế nào?
|74. Vì sao tác giả chọn MSL = 512?
|75. Mỗi tập dữ liệu được huấn luyện trong bao nhiêu epoch?
|76. Vì sao số epoch của Yelp thấp hơn các tập khác?
|77. Dropout và learning rate được điều chỉnh ra sao trong KD?
|78. λ được chọn khác nhau cho bài toán đa nhãn và đơn nhãn như thế nào?
|79. Việc chọn batch size khác nhau giữa hai nhóm dataset có mục đích gì?
|80. Các yếu tố nào quyết định tính ổn định của quá trình distillation?
|
|81. Kết quả nào chứng minh rằng BERTlarge đạt state-of-the-art?
|82. Sự khác biệt giữa BERTbase và BERTlarge là gì?
|83. BERTlarge cải thiện bao nhiêu điểm F1 hoặc accuracy so với BERTbase?
|84. KD-LSTMreg đạt hiệu năng như thế nào so với BERTbase?
|85. Ở dataset nào KD-LSTMreg vượt BERTbase?
|86. Ở dataset nào KD-LSTMreg chưa đạt tới BERTbase?
|87. Kết quả của logistic regression và SVM phản ánh điều gì?
|88. Vì sao LSTMreg vẫn giữ được hiệu năng cao dù đơn giản?
|89. KD-LSTMreg đạt tốc độ suy luận nhanh hơn bao nhiêu lần so với BERTbase?
|90. Ý nghĩa của việc giảm 30× số tham số là gì?
|91. Kết quả nào cho thấy KD-LSTMreg có thể mở rộng tốt?
|92. Ảnh hưởng của số hidden units đến hiệu năng được thể hiện như thế nào trong Figure 1?
|93. Ở mức 256 hidden units, KD-LSTMreg đạt hiệu năng gì so với BERTbase?
|94. Độ dài chuỗi tối đa (MSL) ảnh hưởng như thế nào đến kết quả trên Reuters?
|95. Ảnh hưởng của MSL đến IMDB được thể hiện ra sao?
|96. Tại sao việc cắt bớt chuỗi lại làm giảm mạnh độ chính xác trên IMDB?
|97. Theo Figure 2, cần bao nhiêu epoch để đạt hội tụ trên Reuters và AAPD?
|98. Việc chỉ fine-tune trong 4 epoch ảnh hưởng thế nào đến chất lượng mô hình?
|99.  Những phát hiện nào từ nghiên cứu này có thể mở rộng sang các bài toán NLP khác?|
|100. Hướng nghiên cứu tương lai nào được tác giả đề xuất cho việc nén và tối ưu Transformer?|