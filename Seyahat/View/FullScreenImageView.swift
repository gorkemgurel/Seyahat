//
//  FullScreenImageView.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 25.05.2025.
//

import SwiftUI
import CachedAsyncImage

struct FullScreenImageView: View {
    let imageURL: String
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            CachedAsyncImage(url: URL(string: imageURL)) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } placeholder: {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }

            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()
            }
        }
    }
}

struct FullScreenImageView_Previews: PreviewProvider {
    static var previews: some View {
        FullScreenImageView(imageURL: "https://places.googleapis.com/v1/places/ChIJyeFsRm1SvxQRkaZJWwE2D30/photos/AXQCQNTPA8SQeEdOhx1MV1IITEI-ngpGrj3t8-KPveq-5h3f_E-rFmjw8gTO1msGilQZn2AS1fPUspQv3SfAB1Gt0XhZWh6xEgj945E1h0NLhE5sWdZ_vDjbaAvmokFOsIrtKlE2UtdELYKgan6BHr8oLouKHiGyfVi1Yu0qF7h7kM5HWdRjDxyfMvH1vzP6sTj-dSGVtgCPIWTR03jTrMKUm-ciJsOBgvF1em_9LGMUHYSOeHTaMMCAU34qaXlsh-FmMuWrjyseAooFzlJekdg4rQ9FvgyMqdjDaP8J9kNO_Xm3NF5BC2PlZkOJ0quidJ2YkrhMJynhkOSICnltO2uv3czFP36BFvMMHqYRPI5cW4VI1kl_gSvwqOLZva2-BRRC3CVP8vw0EPAoKrzwH__jyNLATjoWLHfBzrmrZ7ZSS3vIc0e5/media?key=AIzaSyClzVsZd_hH8mBGYe1zlTNnnxY_vfv5ZUI&maxWidthPx=800")
    }
}

