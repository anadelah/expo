/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#pragma once

#include <string>
#include <unordered_map>

#include <ABI45_0_0jsi/ABI45_0_0jsi.h>

#include <ABI45_0_0ReactCommon/ABI45_0_0CallInvoker.h>

namespace ABI45_0_0facebook {
namespace ABI45_0_0React {

/**
 * For now, support the same set of return types as existing impl.
 * This can be improved to support richer typed objects.
 */
enum TurboModuleMethodValueKind {
  VoidKind,
  BooleanKind,
  NumberKind,
  StringKind,
  ObjectKind,
  ArrayKind,
  FunctionKind,
  PromiseKind,
};

/**
 * Base HostObject class for every module to be exposed to JS
 */
class JSI_EXPORT TurboModule : public ABI45_0_0facebook::jsi::HostObject {
 public:
  TurboModule(const std::string &name, std::shared_ptr<CallInvoker> jsInvoker);
  virtual ~TurboModule();

  virtual ABI45_0_0facebook::jsi::Value get(
      ABI45_0_0facebook::jsi::Runtime &runtime,
      const ABI45_0_0facebook::jsi::PropNameID &propName) override;

  const std::string name_;
  std::shared_ptr<CallInvoker> jsInvoker_;

 protected:
  struct MethodMetadata {
    size_t argCount;
    ABI45_0_0facebook::jsi::Value (*invoker)(
        ABI45_0_0facebook::jsi::Runtime &rt,
        TurboModule &turboModule,
        const ABI45_0_0facebook::jsi::Value *args,
        size_t count);
  };

  std::unordered_map<std::string, MethodMetadata> methodMap_;
};

/**
 * An app/platform-specific provider function to get an instance of a module
 * given a name.
 */
using TurboModuleProviderFunctionType =
    std::function<std::shared_ptr<TurboModule>(const std::string &name)>;

} // namespace ABI45_0_0React
} // namespace ABI45_0_0facebook
