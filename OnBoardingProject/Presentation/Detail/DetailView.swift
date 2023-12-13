//
//  DetailView.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/8/23.
//

import UIKit

import Kingfisher
import Then
import SnapKit

class DetailView: UIView {
    lazy var backGroundView = UIView().then {
        $0.backgroundColor = .systemGray4
    }
    
    lazy var bookImageView = UIImageView().then {
        $0.contentMode = .scaleToFill
    }
    
    lazy var infoView = StandardInfoView()
    
    lazy var borderView = UIView().then {
        $0.backgroundColor = .systemGray4
    }
    
    lazy var memoInput = UITextView().then {
        $0.delegate = self
        $0.textColor = .systemGray4
        $0.text = DefaultMSG.Detail.memoPlaceHolder
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.systemGray4.cgColor
        $0.layer.cornerRadius = 16
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        addSubviews([backGroundView, borderView, memoInput, infoView])
        
        backGroundView.snp.makeConstraints {
            $0.leading.trailing.equalTo(safeAreaLayoutGuide)
            $0.top.equalTo(safeAreaLayoutGuide).inset(PaddingStyle.standard)
            $0.height.equalTo(220)
        }
        
        backGroundView.addSubview(bookImageView)
        bookImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(160)
            $0.height.equalTo(200)
        }
        
        infoView.snp.makeConstraints {
            $0.top.equalTo(backGroundView.snp.bottom).offset(PaddingStyle.standardHalf)
            $0.leading.trailing.equalToSuperview().inset(PaddingStyle.standard)
        }
        
        borderView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalTo(infoView).inset(PaddingStyle.standardHalf)
            $0.height.equalTo(1)
            $0.top.equalTo(infoView.snp.bottom).offset(PaddingStyle.standardHalf)
        }
        
        memoInput.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(safeAreaLayoutGuide).inset(PaddingStyle.standard)
            $0.top.equalTo(borderView.snp.bottom).offset(PaddingStyle.standardPlus)
        }
    }
}

extension DetailView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == DefaultMSG.Detail.memoPlaceHolder {
            textView.text = nil
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = DefaultMSG.Detail.memoPlaceHolder
            textView.textColor = .systemGray4
        }
    }
}
