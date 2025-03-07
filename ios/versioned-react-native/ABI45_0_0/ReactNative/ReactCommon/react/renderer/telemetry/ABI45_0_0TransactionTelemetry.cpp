/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#include "ABI45_0_0TransactionTelemetry.h"

#include <ABI45_0_0React/ABI45_0_0debug/ABI45_0_0React_native_assert.h>

#include <utility>

namespace ABI45_0_0facebook {
namespace ABI45_0_0React {

thread_local TransactionTelemetry *threadLocalTransactionTelemetry = nullptr;

TransactionTelemetry::TransactionTelemetry()
    : TransactionTelemetry(telemetryTimePointNow) {}

TransactionTelemetry::TransactionTelemetry(
    std::function<TelemetryTimePoint()> now)
    : now_{std::move(now)} {}

TransactionTelemetry *TransactionTelemetry::threadLocalTelemetry() {
  return threadLocalTransactionTelemetry;
}

void TransactionTelemetry::setAsThreadLocal() {
  threadLocalTransactionTelemetry = this;
}

void TransactionTelemetry::unsetAsThreadLocal() {
  threadLocalTransactionTelemetry = nullptr;
}

void TransactionTelemetry::willCommit() {
  ABI45_0_0React_native_assert(commitStartTime_ == kTelemetryUndefinedTimePoint);
  ABI45_0_0React_native_assert(commitEndTime_ == kTelemetryUndefinedTimePoint);
  commitStartTime_ = now_();
}

void TransactionTelemetry::didCommit() {
  ABI45_0_0React_native_assert(commitStartTime_ != kTelemetryUndefinedTimePoint);
  ABI45_0_0React_native_assert(commitEndTime_ == kTelemetryUndefinedTimePoint);
  commitEndTime_ = now_();
}

void TransactionTelemetry::willDiff() {
  ABI45_0_0React_native_assert(diffStartTime_ == kTelemetryUndefinedTimePoint);
  ABI45_0_0React_native_assert(diffEndTime_ == kTelemetryUndefinedTimePoint);
  diffStartTime_ = now_();
}

void TransactionTelemetry::didDiff() {
  ABI45_0_0React_native_assert(diffStartTime_ != kTelemetryUndefinedTimePoint);
  ABI45_0_0React_native_assert(diffEndTime_ == kTelemetryUndefinedTimePoint);
  diffEndTime_ = now_();
}

void TransactionTelemetry::willLayout() {
  ABI45_0_0React_native_assert(layoutStartTime_ == kTelemetryUndefinedTimePoint);
  ABI45_0_0React_native_assert(layoutEndTime_ == kTelemetryUndefinedTimePoint);
  layoutStartTime_ = now_();
}

void TransactionTelemetry::willMeasureText() {
  ABI45_0_0React_native_assert(
      lastTextMeasureStartTime_ == kTelemetryUndefinedTimePoint);
  lastTextMeasureStartTime_ = now_();
}

void TransactionTelemetry::didMeasureText() {
  numberOfTextMeasurements_++;
  ABI45_0_0React_native_assert(
      lastTextMeasureStartTime_ != kTelemetryUndefinedTimePoint);
  textMeasureTime_ += now_() - lastTextMeasureStartTime_;
  lastTextMeasureStartTime_ = kTelemetryUndefinedTimePoint;
}

void TransactionTelemetry::didLayout() {
  ABI45_0_0React_native_assert(layoutStartTime_ != kTelemetryUndefinedTimePoint);
  ABI45_0_0React_native_assert(layoutEndTime_ == kTelemetryUndefinedTimePoint);
  layoutEndTime_ = now_();
}

void TransactionTelemetry::willMount() {
  ABI45_0_0React_native_assert(mountStartTime_ == kTelemetryUndefinedTimePoint);
  ABI45_0_0React_native_assert(mountEndTime_ == kTelemetryUndefinedTimePoint);
  mountStartTime_ = now_();
}

void TransactionTelemetry::didMount() {
  ABI45_0_0React_native_assert(mountStartTime_ != kTelemetryUndefinedTimePoint);
  ABI45_0_0React_native_assert(mountEndTime_ == kTelemetryUndefinedTimePoint);
  mountEndTime_ = now_();
}

void TransactionTelemetry::setRevisionNumber(int revisionNumber) {
  revisionNumber_ = revisionNumber;
}

TelemetryTimePoint TransactionTelemetry::getDiffStartTime() const {
  ABI45_0_0React_native_assert(diffStartTime_ != kTelemetryUndefinedTimePoint);
  ABI45_0_0React_native_assert(diffEndTime_ != kTelemetryUndefinedTimePoint);
  return diffStartTime_;
}

TelemetryTimePoint TransactionTelemetry::getDiffEndTime() const {
  ABI45_0_0React_native_assert(diffStartTime_ != kTelemetryUndefinedTimePoint);
  ABI45_0_0React_native_assert(diffEndTime_ != kTelemetryUndefinedTimePoint);
  return diffEndTime_;
}

TelemetryTimePoint TransactionTelemetry::getCommitStartTime() const {
  ABI45_0_0React_native_assert(commitStartTime_ != kTelemetryUndefinedTimePoint);
  ABI45_0_0React_native_assert(commitEndTime_ != kTelemetryUndefinedTimePoint);
  return commitStartTime_;
}

TelemetryTimePoint TransactionTelemetry::getCommitEndTime() const {
  ABI45_0_0React_native_assert(commitStartTime_ != kTelemetryUndefinedTimePoint);
  ABI45_0_0React_native_assert(commitEndTime_ != kTelemetryUndefinedTimePoint);
  return commitEndTime_;
}

TelemetryTimePoint TransactionTelemetry::getLayoutStartTime() const {
  ABI45_0_0React_native_assert(layoutStartTime_ != kTelemetryUndefinedTimePoint);
  ABI45_0_0React_native_assert(layoutEndTime_ != kTelemetryUndefinedTimePoint);
  return layoutStartTime_;
}

TelemetryTimePoint TransactionTelemetry::getLayoutEndTime() const {
  ABI45_0_0React_native_assert(layoutStartTime_ != kTelemetryUndefinedTimePoint);
  ABI45_0_0React_native_assert(layoutEndTime_ != kTelemetryUndefinedTimePoint);
  return layoutEndTime_;
}

TelemetryTimePoint TransactionTelemetry::getMountStartTime() const {
  ABI45_0_0React_native_assert(mountStartTime_ != kTelemetryUndefinedTimePoint);
  ABI45_0_0React_native_assert(mountEndTime_ != kTelemetryUndefinedTimePoint);
  return mountStartTime_;
}

TelemetryTimePoint TransactionTelemetry::getMountEndTime() const {
  ABI45_0_0React_native_assert(mountStartTime_ != kTelemetryUndefinedTimePoint);
  ABI45_0_0React_native_assert(mountEndTime_ != kTelemetryUndefinedTimePoint);
  return mountEndTime_;
}

TelemetryDuration TransactionTelemetry::getTextMeasureTime() const {
  return textMeasureTime_;
}

int TransactionTelemetry::getNumberOfTextMeasurements() const {
  return numberOfTextMeasurements_;
}

int TransactionTelemetry::getRevisionNumber() const {
  return revisionNumber_;
}

} // namespace ABI45_0_0React
} // namespace ABI45_0_0facebook
